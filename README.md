# functional-based-encryption-system
# 🔐 Functional-Based Encryption System for Red Channel of Color Image

This project implements a *functional-based encryption system* for the *Red channel* of a color image. The goal is to selectively encrypt only the red channel while leaving the green and blue channels untouched, thereby preserving partial visual data and enabling efficient, targeted encryption.

---

## 🧠 How It Works

### 🔻 1. *Channel Extraction*
- A color image (RGB) is read.
- It is split into its individual *Red, **Green, and **Blue* channels.

### 🔒 2. *Red Channel Encryption*
Encryption is applied *only* to the Red channel using a two-step process:
1. *XOR Encryption using KM Generator (a custom PRNG):*
   - A pseudo-random stream is generated using modular arithmetic.
   - The red channel is XORed with this stream for the first layer of encryption.
2. *Blum Blum Shub (BBS) Functional Encryption:*
   - A cryptographically secure PRNG (BBS) generates a second pseudo-random sequence.
   - This sequence is added modulo 256 to the XOR-encrypted red channel.

The final output is a partially encrypted image with:
- *Encrypted Red channel*
- *Unencrypted Green and Blue channels*

### 🔐 3. *Red Channel Decryption*
Decryption follows the reverse of encryption:
- First, subtract the BBS sequence modulo 256.
- Then, apply XOR decryption using the same PRNG stream to recover the original red channel.

---

## 🛠 Implementation Details

### 🔢 PRNG (KM Generator)
matlab
Xn = mod(Xn * M * I, m);

- Uses seed, multiplier M, irrational constant I, and modulus m for randomness.

### ⚙ XOR Encryption
matlab
EncryptedData = bitxor(uint8(originalData), uint8(randStream));

- Lightweight operation for initial confusion of the red channel.

### 🧬 Blum Blum Shub Functional Encryption
matlab
x = mod(x^2, n); % Secure random stream

- A secure stream is added to further obfuscate the XORed data.

---

## 🖼 Output Images
- *XOR Encrypted Red Channel*
- *BBS Encrypted Red Channel*
- *Final Encrypted Image*
- *Decrypted (partially and fully) Red Channels*

Histograms for original vs encrypted red channels are also displayed to visualize pixel value diffusion.

---

## 📁 Usage

Ensure MATLAB is installed, then run the script. The image URL can be changed to test different inputs. All parameters (seed, M, I, m, bbsSeed, p, q) are customizable for experimental cryptographic analysis.

---

## 🔐 Applications
- Secure transmission of sensitive image data.
- Educational tool to demonstrate layered encryption techniques.
- Experimental cryptography in image processing.
