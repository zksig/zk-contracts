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

library ValidVerifiedParticipantDataPairing {
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

library ValidVerifiedParticipantData {
  using ValidVerifiedParticipantDataPairing for *;
  struct VerifyingKey {
    ValidVerifiedParticipantDataPairing.G1Point alfa1;
    ValidVerifiedParticipantDataPairing.G2Point beta2;
    ValidVerifiedParticipantDataPairing.G2Point gamma2;
    ValidVerifiedParticipantDataPairing.G2Point delta2;
    ValidVerifiedParticipantDataPairing.G1Point[] IC;
  }
  struct Proof {
    ValidVerifiedParticipantDataPairing.G1Point A;
    ValidVerifiedParticipantDataPairing.G2Point B;
    ValidVerifiedParticipantDataPairing.G1Point C;
  }

  function verifyingKey() internal pure returns (VerifyingKey memory vk) {
    vk.alfa1 = ValidVerifiedParticipantDataPairing.G1Point(
      1423427196573326869960381667785122074357921755684386940651843063386195096976,
      8023961015251680984904169932113418146783590031556471530623177414331800090437
    );

    vk.beta2 = ValidVerifiedParticipantDataPairing.G2Point(
      [
        14981788778016161064675824813766262164386590279136355427549180094813413442058,
        15280203404894510920756392128045715359164951458648562381898759371631084950081
      ],
      [
        127457706682557739436150116433930019448698159193059553212687691311716440831,
        17421767135883714886528432224440823873509790917646536951997623325206225910141
      ]
    );
    vk.gamma2 = ValidVerifiedParticipantDataPairing.G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.delta2 = ValidVerifiedParticipantDataPairing.G2Point(
      [
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781
      ],
      [
        4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930
      ]
    );
    vk.IC = new ValidVerifiedParticipantDataPairing.G1Point[](5);

    vk.IC[0] = ValidVerifiedParticipantDataPairing.G1Point(
      18581483682637461615879095853773447470894295748938643847366637153271124856706,
      15310135758487381292574002235520202902902059006802570985327558876160220394979
    );

    vk.IC[1] = ValidVerifiedParticipantDataPairing.G1Point(
      17107171535465837836616395508743960259455100312001430863607969762902997896752,
      3246426186895176385651990199440031581568623745362030805991493678651697912356
    );

    vk.IC[2] = ValidVerifiedParticipantDataPairing.G1Point(
      19807740958714008947825573318736160557429424992200524508473298666610680690856,
      9500958468977522065957590169900379815211209999981183588815629843018604951596
    );

    vk.IC[3] = ValidVerifiedParticipantDataPairing.G1Point(
      18985600279471168561155786338731339249853860713181429724156103759249790054095,
      3694230909553553329699418598761590307530868619693497776745756779055275413538
    );

    vk.IC[4] = ValidVerifiedParticipantDataPairing.G1Point(
      20701897565758172403951452993531771697629836522450906362552732734274076039132,
      2617926701833225213750895711255371535358817398747092277644229622612663844659
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
    ValidVerifiedParticipantDataPairing.G1Point
      memory vk_x = ValidVerifiedParticipantDataPairing.G1Point(0, 0);
    for (uint i = 0; i < input.length; i++) {
      require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
      vk_x = ValidVerifiedParticipantDataPairing.addition(
        vk_x,
        ValidVerifiedParticipantDataPairing.scalar_mul(vk.IC[i + 1], input[i])
      );
    }
    vk_x = ValidVerifiedParticipantDataPairing.addition(vk_x, vk.IC[0]);
    if (
      !ValidVerifiedParticipantDataPairing.pairingProd4(
        ValidVerifiedParticipantDataPairing.negate(proof.A),
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
    uint[4] memory input
  ) public view returns (bool r) {
    Proof memory proof;
    proof.A = ValidVerifiedParticipantDataPairing.G1Point(a[0], a[1]);
    proof.B = ValidVerifiedParticipantDataPairing.G2Point(
      [b[0][0], b[0][1]],
      [b[1][0], b[1][1]]
    );
    proof.C = ValidVerifiedParticipantDataPairing.G1Point(c[0], c[1]);
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
