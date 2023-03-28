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
pragma solidity ^0.8.18;

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
      20491192805390485299153009773594534940189261866228447918068658471970481763042,
      9383485363053290200918347156157836566562967994039712273449902621266178545958
    );

    vk.beta2 = ProofOfSignaturePairing.G2Point(
      [
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        6375614351688725206403948262868962793625744043794305715222011528459656738731
      ],
      [
        21847035105528745403288232691147584728191162732299865338377159692350059136679,
        10505242626370262277552901082094356697409835680220590971873171140371331206856
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
        12370494022557528586342325116637285399564725754494509059991356212821722836314,
        9103930241912937998952893336103559993029416080835783211976556004998638166360
      ],
      [
        15738166188209331323017844240452979840511816624886815988585090269434987965844,
        717258749469745112197303618909100369749841689508753158157764072372752572305
      ]
    );
    vk.IC = new ProofOfSignaturePairing.G1Point[](9);

    vk.IC[0] = ProofOfSignaturePairing.G1Point(
      17092741742987951428708028485451641401231727146926180867122080033689460935247,
      5907093358208768801958516825569563377468310295566077336924616118320125121372
    );

    vk.IC[1] = ProofOfSignaturePairing.G1Point(
      1481374536321309501465188724564385218758875549305966852289720153465457014761,
      16276215841992714269361859423253161561615142772363045652630074425880799669244
    );

    vk.IC[2] = ProofOfSignaturePairing.G1Point(
      17614732352951784753361406036973660249719225768106782430902432958746179318516,
      17002961439351454562277707876099606431069779555102587669567485160456658860467
    );

    vk.IC[3] = ProofOfSignaturePairing.G1Point(
      15689264753412553112554922040701901126744891786640349215386993457134176079048,
      17139805150220846358976363132363653352443013865942171520939213931026858463132
    );

    vk.IC[4] = ProofOfSignaturePairing.G1Point(
      15412968605667487694082473625388723746765768611503304286466475611950446809229,
      14548254568568045677168129935541465270455691620414404746471366792601087327154
    );

    vk.IC[5] = ProofOfSignaturePairing.G1Point(
      14008943245475998152513508938201327304167871651728603186257981101582563754246,
      6515529170027894712869378044098113575402975104448446046858696662407314035227
    );

    vk.IC[6] = ProofOfSignaturePairing.G1Point(
      9507675005270367695782419281410792132890459702754179416536139283529016201377,
      1376804354666006605998408509355161300658799914693624238950428741801536852300
    );

    vk.IC[7] = ProofOfSignaturePairing.G1Point(
      3948167945673758084122623364017125309896844330419331918815474700539333957813,
      19031619855536905897937530040495808692281017237578263641313488259835459127696
    );

    vk.IC[8] = ProofOfSignaturePairing.G1Point(
      8552887827501388647213609461349370820045391497272586233691858993068153302984,
      13017658430138973067525410616812665591688043635871781960533472554927349219059
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
