//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

library ProofOfSignaturePairing {
  struct G1Point {
    uint X;
    uint Y;
  }
  // Encoding of field elements is: X[0] * z + X[1]
  struct G2Point {
    uint[2] X;
    uint[2] Y;
  }

  /// @return the generator of G1
  function P1() internal pure returns (G1Point memory) {
    return G1Point(1, 2);
  }

  /// @return the generator of G2
  function P2() internal pure returns (G2Point memory) {
    // Original code point
    return
      G2Point(
        [
          11559732032986387107991004021392285783925812861821192530917403151452391805634,
          10857046999023057135944570762232829481370756359578518086990519993285655852781
        ],
        [
          4082367875863433681332203403145435568316851327593401208105741076214120093531,
          8495653923123431417604973247489272438418190587263600148770280649306958101930
        ]
      );

    /*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
  }

  /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
  function negate(G1Point memory p) internal pure returns (G1Point memory r) {
    // The prime q in the base field F_q for G1
    uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
    return G1Point(p.X, q - (p.Y % q));
  }

  /// @return r the sum of two points of G1
  function addition(
    G1Point memory p1,
    G1Point memory p2
  ) internal view returns (G1Point memory r) {
    uint[4] memory input;
    input[0] = p1.X;
    input[1] = p1.Y;
    input[2] = p2.X;
    input[3] = p2.Y;
    bool success;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success, "pairing-add-failed");
  }

  /// @return r the product of a point on G1 and a scalar, i.e.
  /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
  function scalar_mul(
    G1Point memory p,
    uint s
  ) internal view returns (G1Point memory r) {
    uint[3] memory input;
    input[0] = p.X;
    input[1] = p.Y;
    input[2] = s;
    bool success;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success, "pairing-mul-failed");
  }

  /// @return the result of computing the pairing check
  /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
  /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
  /// return true.
  function pairing(
    G1Point[] memory p1,
    G2Point[] memory p2
  ) internal view returns (bool) {
    require(p1.length == p2.length, "pairing-lengths-failed");
    uint elements = p1.length;
    uint inputSize = elements * 6;
    uint[] memory input = new uint[](inputSize);
    for (uint i = 0; i < elements; i++) {
      input[i * 6 + 0] = p1[i].X;
      input[i * 6 + 1] = p1[i].Y;
      input[i * 6 + 2] = p2[i].X[0];
      input[i * 6 + 3] = p2[i].X[1];
      input[i * 6 + 4] = p2[i].Y[0];
      input[i * 6 + 5] = p2[i].Y[1];
    }
    uint[1] memory out;
    bool success;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      success := staticcall(
        sub(gas(), 2000),
        8,
        add(input, 0x20),
        mul(inputSize, 0x20),
        out,
        0x20
      )
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success, "pairing-opcode-failed");
    return out[0] != 0;
  }

  /// Convenience method for a pairing check for two pairs.
  function pairingProd2(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](2);
    G2Point[] memory p2 = new G2Point[](2);
    p1[0] = a1;
    p1[1] = b1;
    p2[0] = a2;
    p2[1] = b2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for three pairs.
  function pairingProd3(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](3);
    G2Point[] memory p2 = new G2Point[](3);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for four pairs.
  function pairingProd4(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2,
    G1Point memory d1,
    G2Point memory d2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](4);
    G2Point[] memory p2 = new G2Point[](4);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p1[3] = d1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    p2[3] = d2;
    return pairing(p1, p2);
  }
}

library ProofOfSignature {
  using ProofOfSignaturePairing for *;
  struct VerifyingKey {
    ProofOfSignaturePairing.G1Point alfa1;
    ProofOfSignaturePairing.G2Point beta2;
    ProofOfSignaturePairing.G2Point gamma2;
    ProofOfSignaturePairing.G2Point delta2;
    ProofOfSignaturePairing.G1Point[] IC;
  }
  struct Proof {
    ProofOfSignaturePairing.G1Point A;
    ProofOfSignaturePairing.G2Point B;
    ProofOfSignaturePairing.G1Point C;
  }

  function verifyingKey() internal pure returns (VerifyingKey memory vk) {
    vk.alfa1 = ProofOfSignaturePairing.G1Point(
      1423427196573326869960381667785122074357921755684386940651843063386195096976,
      8023961015251680984904169932113418146783590031556471530623177414331800090437
    );

    vk.beta2 = ProofOfSignaturePairing.G2Point(
      [
        14981788778016161064675824813766262164386590279136355427549180094813413442058,
        15280203404894510920756392128045715359164951458648562381898759371631084950081
      ],
      [
        127457706682557739436150116433930019448698159193059553212687691311716440831,
        17421767135883714886528432224440823873509790917646536951997623325206225910141
      ]
    );
    vk.gamma2 = ProofOfSignaturePairing.G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = ProofOfSignaturePairing.G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.IC = new ProofOfSignaturePairing.G1Point[](9);

    vk.IC[0] = ProofOfSignaturePairing.G1Point(
      9574364421654618867433280770669466662379579360138576253706933591960956755087,
      20231222178273319014502809142392526341901061210661080302298348064428386157929
    );

    vk.IC[1] = ProofOfSignaturePairing.G1Point(
      536039037643951195302414110883600395592568749081715892563571898204379445139,
      19870850498766860689711737392031956613856173281213852326106501046887412336083
    );

    vk.IC[2] = ProofOfSignaturePairing.G1Point(
      21177289243044005760648164128581852896390184043545129490542669916514055942335,
      11053081472111752143909811170892678436806869069410546080084311474131213545974
    );

    vk.IC[3] = ProofOfSignaturePairing.G1Point(
      14738740517535862650225813290886698862637536723703129348434347507141678411987,
      15803838574190207195645965217701969955698161329634765554788642950120953528208
    );

    vk.IC[4] = ProofOfSignaturePairing.G1Point(
      11139246204485600505523904076285444319808113119431425086597625511102831983320,
      3472034541783821347063630402595171920573024644028618027414889889261984442410
    );

    vk.IC[5] = ProofOfSignaturePairing.G1Point(
      3254225389408597744024726278437125501640014944208448215732987861418316974315,
      5691352971200222919192988981171490127546025615741859172817377921041695743151
    );

    vk.IC[6] = ProofOfSignaturePairing.G1Point(
      14389181365173960826618499116342736875316697691870702752596307064146224006124,
      10781773245491578700849013558983809317254607115998237118414834275481237269402
    );

    vk.IC[7] = ProofOfSignaturePairing.G1Point(
      16697902500187413640679424913119192128144384576671654353929272084714050681273,
      4324909635786578542528957587892558174095515164603448447558180221409868739346
    );

    vk.IC[8] = ProofOfSignaturePairing.G1Point(
      15669410565300183855888206748819329121241239593181651311548534358088268223206,
      12311258461354435790336759261243387660352469627675601128110757795942261346509
    );
  }

  function verify(
    uint[] memory input,
    Proof memory proof
  ) internal view returns (uint) {
    uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    VerifyingKey memory vk = verifyingKey();
    require(input.length + 1 == vk.IC.length, "verifier-bad-input");
    // Compute the linear combination vk_x
    ProofOfSignaturePairing.G1Point memory vk_x = ProofOfSignaturePairing
      .G1Point(0, 0);
    for (uint i = 0; i < input.length; i++) {
      require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
      vk_x = ProofOfSignaturePairing.addition(
        vk_x,
        ProofOfSignaturePairing.scalar_mul(vk.IC[i + 1], input[i])
      );
    }
    vk_x = ProofOfSignaturePairing.addition(vk_x, vk.IC[0]);
    if (
      !ProofOfSignaturePairing.pairingProd4(
        ProofOfSignaturePairing.negate(proof.A),
        proof.B,
        vk.alfa1,
        vk.beta2,
        vk_x,
        vk.gamma2,
        proof.C,
        vk.delta2
      )
    ) return 1;
    return 0;
  }

  /// @return r  bool true if proof is valid
  function verifyProof(
    uint[2] memory a,
    uint[2][2] memory b,
    uint[2] memory c,
    uint[8] memory input
  ) public view returns (bool r) {
    Proof memory proof;
    proof.A = ProofOfSignaturePairing.G1Point(a[0], a[1]);
    proof.B = ProofOfSignaturePairing.G2Point(
      [b[0][0], b[0][1]],
      [b[1][0], b[1][1]]
    );
    proof.C = ProofOfSignaturePairing.G1Point(c[0], c[1]);
    uint[] memory inputValues = new uint[](input.length);
    for (uint i = 0; i < input.length; i++) {
      inputValues[i] = input[i];
    }
    if (verify(inputValues, proof) == 0) {
      return true;
    } else {
      return false;
    }
  }
}
