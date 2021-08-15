<!-- for hacker slides https://oasis.sandstorm.io/shared/WZhm-ZJ9ZvQHGQTTyekSo-GnYHyiZp8cDhdKRKmaow8 --> 

# 

## Crafting Cryptographic Systems in Coq

<img height="300px" src="https://deepspec.org/img/research/crypto.png">

Andres Erbsen  
June 2018

<p style="font-size: 26px">
Asya Bergal,
Adam Chlipala,
Istvan Chung,
Jason Gross,
Jade Philipoom,
Robert Sloan
</p>

<!-- .slide: data-transition="zoom" -->

---

## Motivating Vision:

One system outside the "cat and mouse" security treadmill

- Secure messaging
- Wire-to-wire semantics
- End-to-end security verification
- Modular code and proofs
- Independently useful components

---

## Essential Components — Categorization and Examples

| | characteristic | examples  |
| --- | --- | --- |
| protocols     | interactive |  TLS1.3, Signal |
| constructions | provable | HKDF, Poly1305  |
| primitives    | conjectured | SHA2, Curve25519   |
| low-level code|  | bedrock2, Clight |
| hardware      |  | pipelined RISC-V  |

<!-- .slide: data-transition="fade" -->

--

## Verification Approaches — Prior Work And Challenges

|   |   correctness   | security |
| --- | --- | --- |
| protocols     | *state-machine* | *CryptoVerif?* |
| constructions |  write; prove  | FCF |
| primitives    |  *repetition*   | ~~empirical~~ |
| low-level code| bedrock2, Clight |  |
| hardware     |  Kami  | *timing leaks* |

<!-- .slide: data-transition="fade" -->

--

## Verification Approaches — Current Work

|   |   correctness   | security |
| --- | --- | --- |
| protocols     |    | **CCSA** |
| constructions |  write; prove  | FCF |
| primitives    |  **fiat-crypto**   | ~~empirical~~ |
| low-level code| bedrock2, Clight |   |
| hardware     |  Kami  | abs. interp. |

<!-- .slide: data-transition="fade" -->

--

## Verification Approaches — Planned

|   |   correctness   | security |
| --- | --- | --- |
| protocols     |  SM compiler  | **CCSA<sup>n</sup>**? |
| constructions |  write; prove  | FCF |
| primitives    |  **fiat-crypto**   | ~~empirical~~ |
| low-level code| bedrock2, Clight |   |
| hardware     |  Kami  | i/o batching |

<!-- .slide: data-transition="fade" -->

---

## Example: Curve25519

- Specification: `λ a b, a*b mod (2^255-19)`
- Conventional implementation
    - specialized 257-bit inputs
    - specialized to `p = 2^255-19`
    - specialized to 128-bit MUL instruction
    - specialized to 5 registers of ~51 bits each
    - loops manually unrolled, quadratic blowup

--

<pre>  mulrax = *(uint64 *)(xp + 24)
  mulrax *= 19
  mulx319_stack = mulrax
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 16)
  r0 = mulrax
  mulr01 = mulrdx
  mulrax = *(uint64 *)(xp + 32)
  mulrax *= 19
  mulx419_stack = mulrax
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 8)
  carry? r0 += mulrax
  mulr01 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 0)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 0)
  carry? r0 += mulrax
  mulr01 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 0)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 8)
  r1 = mulrax
  mulr11 = mulrdx
  mulrax = *(uint64 *)(xp + 0)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 16)
  r2 = mulrax
  mulr21 = mulrdx
  mulrax = *(uint64 *)(xp + 0)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 24)
  r3 = mulrax
  mulr31 = mulrdx
  mulrax = *(uint64 *)(xp + 0)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 32)
  r4 = mulrax
  mulr41 = mulrdx
  mulrax = *(uint64 *)(xp + 8)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 0)
  carry? r1 += mulrax
  mulr11 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 8)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 8)
  carry? r2 += mulrax
  mulr21 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 8)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 16)
  carry? r3 += mulrax
  mulr31 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 8)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 24)
  carry? r4 += mulrax
  mulr41 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 8)
  mulrax *= 19
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 32)
  carry? r0 += mulrax
  mulr01 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 16)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 0)
  carry? r2 += mulrax
  mulr21 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 16)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 8)
  carry? r3 += mulrax
  mulr31 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 16)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 16)
  carry? r4 += mulrax
  mulr41 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 16)
  mulrax *= 19
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 24)
  carry? r0 += mulrax
  mulr01 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 16)
  mulrax *= 19
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 32)
  carry? r1 += mulrax
  mulr11 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 24)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 0)
  carry? r3 += mulrax
  mulr31 += mulrdx + carry
  mulrax = *(uint64 *)(xp + 24)
  (uint128) mulrdx mulrax = mulrax * *(uint64 *)(yp + 8)
  carry? r4 += mulrax
</pre>

--

> For example, four implementations of the ed25519 signature
system have been publicly available and waiting for integration into NaCl since 2011, but
in total they consist of 5521 lines of C code and **16184 lines of qhasm code**. Partial audits have revealed
a **bug in this software (r1 += 0 + carry should be r2 += 0 + carry in amd64-64-24k)**
that would not be caught by random tests; this illustrates the importance of audits.

<https://tweetnacl.cr.yp.to/tweetnacl-20140917.pdf>  
(emphasis added)

---

## Example: P256

- `λa b, a*b mod (2^256-2^224+2^192+2^96-1)`
- Conventional implementation (different algorithm)
    - specialized 256-bit inputs
    - specialized to `p = 2^256-2^224+2^192+2^96-1`
    - specialized to 128-bit MUL and 64-bit ADC
    - specialized to 4 registers of 64 bits each
    - loops manually unrolled, quadratic blowup

--

<pre>__ecp_nistz256_mul_montx:
# Multiply by b[0]
mulx	$acc1, $acc0, $acc1
mulx	$acc2, $t0, $acc2
mov	\$32, $poly1
xor	$acc5, $acc5		# cf=0
mulx	$acc3, $t1, $acc3
mov	.Lpoly+8*3(%rip), $poly3
adc	$t0, $acc1
mulx	$acc4, $t0, $acc4
 mov	$acc0, %rdx
adc	$t1, $acc2
 shlx	$poly1,$acc0,$t1
adc	$t0, $acc3
 shrx	$poly1,$acc0,$t0
adc	\$0, $acc4
# First reduction step
add	$t1, $acc1
adc	$t0, $acc2
mulx	$poly3, $t0, $t1
 mov	8*1($b_ptr), %rdx
adc	$t0, $acc3
adc	$t1, $acc4
adc	\$0, $acc5
xor	$acc0, $acc0		# $acc0=0,cf=0,of=0# Multiply by b[1]
mulx	8*0+128($a_ptr), $t0, $t1
adcx	$t0, $acc1
adox	$t1, $acc2
mulx	8*1+128($a_ptr), $t0, $t1
adcx	$t0, $acc2
adox	$t1, $acc3
mulx	8*2+128($a_ptr), $t0, $t1
adcx	$t0, $acc3
adox	$t1, $acc4
mulx	8*3+128($a_ptr), $t0, $t1
 mov	$acc1, %rdx
adcx	$t0, $acc4
 shlx	$poly1, $acc1, $t0
adox	$t1, $acc5
 shrx	$poly1, $acc1, $t1
adcx	$acc0, $acc5
adox	$acc0, $acc0
adc	\$0, $acc0
</pre>

--

[openssl#3607: nistz256 is broken](https://rt.openssl.org/Ticket/Display.html?id=3607&user=guest&pass=guest)


> [...] under "Now the reduction" there are a number of comments saying "doesn't overflow". Unfortunately, they aren't correct.

Author response:

> Got math wrong:-(

After fix:

> It's good for ~6B random tests.


---

## fiat-crypto

- Solinas reduction and Montgomery reduction
- Templates parametrized over representation
- **Prove correctness of templates** once
   - always correct, fast with right arguments
- Specialize, pretty-print C, compile
- Work in ℤ, infer widths of variables
- Syntactically enforce "constant-time" code

--

<pre>static void femul_25519(uint64_t out[5], const uint64_t in1[5], const uint64_t in2[5]) {
  // ... (load inputs into variables)
  { uint128_t x20 = ((uint128_t)x5 * x13);
  { uint128_t x21 = (((uint128_t)x5 * x15) + ((uint128_t)x7 * x13));
  { uint128_t x22 = ((((uint128_t)x5 * x17) + ((uint128_t)x9 * x13)) + ((uint128_t)x7 * x15));
  { uint128_t x23 = (((((uint128_t)x5 * x19) + ((uint128_t)x11 * x13)) + ((uint128_t)x7 * x17)) + ((uint128_t)x9 * x15));
  { uint128_t x24 = ((((((uint128_t)x5 * x18) + ((uint128_t)x10 * x13)) + ((uint128_t)x11 * x15)) + ((uint128_t)x7 * x19)) + ((uint128_t)x9 * x17));
  { uint64_t x25 = (x10 * 0x13);
  { uint64_t x26 = (x7 * 0x13);
  { uint64_t x27 = (x9 * 0x13);
  { uint64_t x28 = (x11 * 0x13);
  { uint128_t x29 = ((((x20 + ((uint128_t)x25 * x15)) + ((uint128_t)x26 * x18)) + ((uint128_t)x27 * x19)) + ((uint128_t)x28 * x17));
  { uint128_t x30 = (((x21 + ((uint128_t)x25 * x17)) + ((uint128_t)x27 * x18)) + ((uint128_t)x28 * x19));
  { uint128_t x31 = ((x22 + ((uint128_t)x25 * x19)) + ((uint128_t)x28 * x18));
  { uint128_t x32 = (x23 + ((uint128_t)x25 * x18));
  { uint64_t x33 = (uint64_t) (x29 >> 0x33);
  { uint64_t x34 = ((uint64_t)x29 & 0x7ffffffffffff);
  { uint128_t x35 = (x33 + x30);
  { uint64_t x36 = (uint64_t) (x35 >> 0x33);
  { uint64_t x37 = ((uint64_t)x35 & 0x7ffffffffffff);
  { uint128_t x38 = (x36 + x31);
  { uint64_t x39 = (uint64_t) (x38 >> 0x33);
  { uint64_t x40 = ((uint64_t)x38 & 0x7ffffffffffff);
  { uint128_t x41 = (x39 + x32);
  { uint64_t x42 = (uint64_t) (x41 >> 0x33);
  { uint64_t x43 = ((uint64_t)x41 & 0x7ffffffffffff);
  { uint128_t x44 = (x42 + x24);
  { uint64_t x45 = (uint64_t) (x44 >> 0x33);
  { uint64_t x46 = ((uint64_t)x44 & 0x7ffffffffffff);
  { uint64_t x47 = (x34 + (0x13 * x45));
  { uint64_t x48 = (x47 >> 0x33);
  { uint64_t x49 = (x47 & 0x7ffffffffffff);
  { uint64_t x50 = (x48 + x37);
  { uint64_t x51 = (x50 >> 0x33);
  { uint64_t x52 = (x50 & 0x7ffffffffffff);
</pre>

--

### Curve25519 on Broadwell

| Implementation       | Cycles   |
|----------------------|----------|
| `amd64-64` (qhasm)   | `151586` |
| `fiat-crypto` (Coq)  | `152195` |
| `sandy2x` (qhasm)    | `154313` |
| `hacl-star` (Low*)   | `154982` |
| `donna64` (C)        | `168502` |

--

### P256 on Broadwell

|  Implementation        | Cycles      |
|------------------------|-------------|
| `nistz256adx` (perlasm) |  `~550` |
| `fiat-crypto` (Coq)     |  `1143` |
| OpenSSL (C)             |  `1151` |

---

160-line demo  
(code + proof)

---


### Portable C Code

- <chrome://credits/>
- Included through BoringSSL
    - also in Google servers, Android, CloudFlare, ...
- WireGuard

---

## Protocol Security Background

- Computational model: list intractable computations
    - "attacker can't distinguish (g<sup>x</sup>,g<sup>y</sup>,g<sup>z</sup>) and (g<sup>x</sup>,g<sup>y</sup>,g<sup>xy</sup>)"
    - arguably representative of real time-tested conjectures
- Symbolic model: list derivation rules available to attacker
    - "attacker can **only** compute m from E<sub>k</sub>(m) given k"
    - wishful thinking from formal reasoning

- Computational Soundness: prove the implication?
    - limited sets of primitives and protocols
    - soundness proofs are not composable

---

## Computationally Complete Symbolic Attacker

- Aiming for the best of both approaches
- For fixed-length protocols
- Symbolic formulas with computational interpretation

[Gergei Bana and Rohit Chadha, 2016. "Verification Methods for the Computationally Complete Symbolic Attacker Based on Indistinguishability"](https://eprint.iacr.org/2016/069.pdf)

--

<pre style="font-size: 32px; margin-top:-5mm">
expressions ::= c       -- value constant
              | f e     -- function constant app.
              | (e, e)  -- pairing
              | rand(i) -- REFERENCE to randomness
              | adversarial(e)
assertions ::= e ≈ e    -- computationally indist.
</pre>

<div style="font-size: 36px" class="fragment">
<p style="margin-top:8mm;">⌊expression⌋<sub>adversary, security parameter</sub> : distribution</p>
<p style="margin-top:8mm;">⌊xor (rand(i), rand(i))⌋<sub>\_,\_</sub> = 0</p>

<p style="margin-top:8mm;"  class="fragment">
a ≈ b ≝  
∀ A, limited A →  
  negligible **(**λ η,   
    Pr**[** A(⌊a⌋<sub>A,η</sub>) **]**  –   
     Pr**[**  A(⌊b⌋<sub>A,η</sub>) **|** **)**
</p>
</span>

--


a = b ≝ is_equal(a, b) ≈ true  
- congruence
- e ≈ c ⟷ e = c

<div style="margin-top:8mm;"  class="fragment">
<p style="margin-top:8mm;">
rand(i) = rand(i)<br>
rand(i) ≈ rand(i)  
</p>

<div style="font-size: 36px" class="fragment">
<p style="margin-top:8mm;">
for i ≠ j,<br>
rand(i) ≠ rand(j)<br>
rand(i) ≈ rand(j)  
<div style="font-size: 36px" class="fragment">
(rand(i), rand(i)) ≉ (rand(i), rand(j))
</div>
</p>
</div>
</div>

---

### Network interaction

<pre>
                 .       
                 .       
    +------------+       
    V                    
+--------+               
|  step  |               
+--------+               
 |  +------------+       
 |               V       
 |         +-----------+ 
 |         |adversarial| 
 |         +-----------+ 
 |  +------------+       
 V  V                    
+--------+               
|  step  |               
+--------+               
 |  +------------+       
 |               V       
 |         +-----------+ 
 |         |adversarial| 
 |         +-----------+ 
 |               |       
 .               .       
</pre>
<!-- .slide: data-transition="fade" -->

--

### Network interaction

<pre>
                 .                                         .           
                 .                                         .       
    +------------+                            +------------+       
    V                                         V                     
+--------+                                +--------+               
|  step  |                                |  step' |               
+--------+                                +--------+               
 |  +------------+                         |  +------------+       
 |               V                         |               V       
 |         +-----------+                   |         +-----------+ 
 |         |adversarial|                   |         |adversarial| 
 |         +-----------+         ≈         |         +-----------+ 
 |  +------------+                         |  +------------+       
 V  V                                      V  V                    
+--------+                                +--------+               
|  step  |                                |  step' |               
+--------+                                +--------+               
 |  +------------+                         |  +------------+       
 |               V                         |               V       
 |         +-----------+                   |         +-----------+ 
 |         |adversarial|                   |         |adversarial| 
 |         +-----------+                   |         +-----------+ 
 |               |                         |               |       
 .               .                         .               .       
</pre>
<!-- .slide: data-transition="fade" -->

--

### Network interaction

- n-step interaction is an expression of depth O(n)
- input<sub>n</sub> = adversarial(output<sub>0</sub>,
output<sub>1</sub>,
... ,
output<sub>n-1</sub>)
- (state<sub>n</sub>, output<sub>n</sub>) = subst (state<sub>n-1</sub>, input<sub>n</sub>) into **e<sub>step</sub>**
    - subst must ensure randomness in e<sub>step</sub> is fresh!
<p  style="margin-top:3mm;">    
- No distinction between honest parties in the model
- Messages tagged with "From" and "To"
</p>


--

### Specifying Security Primitives

- Conclusion: ≈ (and derived notions =, ∧, ∨, →)
- Preconditions: syntax-directed inductive predicates
   - Contrast with security by typing
- Rewrite rules applied automatically

- Example (IND-CPA): if a random key has been only used to encrypt, two expressions encrypting different messages are indistinguishable  <!-- .element: class="fragment" -->
    - ...only if equal nonces encrypt equal messages  <!-- .element: class="fragment" -->

--

#### Authenticators

<pre style="font-size: 24px">
auth_safe k e [m1; m2; ...] →
if verify($k,m,s) then C[m]                    else err
=
if verify($k,m,s) then choice(C[m1],C[m2],...) else err

Inductive auth_safe : forall key expr signed, Prop :=
| ASs m l: auth_safe k m l → auth_safe k (sign($k,m)) (m::l)
| ASv m s:                   auth_safe k (verify($k,m,s)) []
| ASr i  : i <> k →          auth_safe k ($i)             []
| ... (* recursive cases *).

</pre>

---

authentication from secrecy

--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +--> encrypt -> mac -> |           |
    |                      |           +-----------------------+
    |                      |           |                       |
    |                      +-----------+--> vermac --> decrypt |
    +------+                                             |     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |  |                                                |
           |  |                                                |
           |  +-----------------------+                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->

--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +--> encrypt -> mac -> |           |
    |                      |           +-----------------------+
    |                      |           |                       |
    |                      +-----------+--> vermac --> decrypt |
    +------+                                             |     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |  |                                                |
           |  |         *could reveal sk here*                 |
           |  +-----------------------+                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->

--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +--> encrypt -+>mac -> |           |
    |             |        |           +-----------------------+
    |             |        |           |                       |
    |             |        +-----------+     +-------> decrypt |
    +------+      +--------------------------+           |     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |  |                                                |
           |  |                                                |
           |  +-----------------------+                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->

--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +--> encrypt -+>mac -> |           |
    |                      |           +-----------------------+
    |                      |           |                       |
    |                      +-----------+                       |
    +------+---------------------------------------------+     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |  |                                                |
           |  |                                                |
           |  +-----------------------+                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->
--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +                      |           |
    |                      |           +-----------------------+
    |                      |           |                       |
    |                      +-----------+                       |
    +------+---------------------------------------------v     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |  |                                                |
           |  |                                                |
           |  +-----------------------+                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->

--

<pre>
        encryption_key = rand(0)     mac_key = rand(1)


                           +-----------+
 sk=rand(2) --> pubkey --> |           |
    |                      |adversarial|
    +                      |           |
    |                      |           +-----------------------+
    |                      |           |                       |
    |                      +-----------+                       |
    +------+---------------------------------------------v     |
           |               +-----------+<---------------sign<--+
           |               |           |                       |
           |               |adversarial|                       |
           |  +------------+           |                       |
           v  v            |           |                       |
          versig <---------+-----------+                       |
           |                                                   |
           +                          +------------------------+
           |                          |                        |
           |                          |                        |
           |                          |                        |
whp (  if  *     then left output     *  equals right output   *  )
</pre>

<!-- .slide: data-transition="fade" -->

--


automated proof

---


### Future Work

- Prove soundness of syntactic rules
- Extend input language through translation
- Prove n-step security for all n by induction
    - Non-trivial inductive invariants (e.g. ratcheting)
- Quantify reduction efficiency for concrete n-step proofs
    - Not even polynomial by construction
---

thanks

