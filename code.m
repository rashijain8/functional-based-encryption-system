% Step 1: Define the parameters for the PRNG (K.M. Generator)
function [RandStream] = KM_Generator(seed, M, I, m, dataSize)
  Xn = seed; % Initial Seed Value
  RandStream = zeros(1, dataSize); % Preallocate for random stream
  for i = 1:dataSize
      Xn = mod(Xn * M * I, m); % PRNG Formula
      RandStream(i) = Xn; % Directly store the generated number
  end
end
% Step 2: XOR Operation for Optimal Encryption Padding (OEP)
function [EncryptedData] = XOR_Encrypt(originalData, randStream)
  % Reshape randStream to match the dimensions of the image data
  randStream = reshape(randStream(1:numel(originalData)), size(originalData));
  EncryptedData = bitxor(uint8(originalData), uint8(randStream)); % XOR operation
end
% Step 3: Generate Blum Blum Shub sequence
function bbsSequence = generate_bbs(seed, n, numBits)
   x = mod(seed^2, n); % Initial state
   bbsSequence = zeros(1, numBits); % Preallocate sequence array
   for i = 1:numBits
       x = mod(x^2, n); % Generate next state
       bbsSequence(i) = mod(x, 256); % Use lower byte as pseudo-random value
   end
end
% Main Function to perform encryption (only on the red channel)
function [EncryptedRedChannel, FinalEncryptedRedChannel] = functionalBasedEncryption(originalData, seed, M, I, m, bbsSeed, n)
  % Generate Random Stream using PRNG
  randStream = KM_Generator(seed, M, I, m, numel(originalData));
  % XOR Encryption (only for Red channel)
  xorEncryptedRed = XOR_Encrypt(originalData, randStream);
 
  % Generate BBS sequence for further encryption
  bbsSequence = generate_bbs(bbsSeed, n, numel(originalData));
  bbsSequenceReshaped = reshape(bbsSequence(1:numel(xorEncryptedRed)), size(xorEncryptedRed));
 
  % Apply BBS encryption on the XORed data
  FinalEncryptedRedChannel = mod(double(xorEncryptedRed) + bbsSequenceReshaped, 256);
  EncryptedRedChannel = xorEncryptedRed; % Return XORed data for intermediate display
end
% Main script to load image, bifurcate into RGB, encrypt only red channel, and display results
fileName = 'https://img.freepik.com/free-photo/colorful-heart-air-balloon-shape-collection-concept-isolated-color-background-beautiful-heart-ball-event_90220-1047.jpg?size=626&ext=jpg&ga=GA1.1.1819120689.1728432000&semt=ais_hybrid'; % Change this to any image file you have
originalImage = imread(fileName);
if size(originalImage, 3) == 1
  originalImage = repmat(originalImage, [1 1 3]);
  disp('The image was grayscale and has been converted to RGB.');
end
figure, imshow(originalImage), title('Original Image');
% Extract the Red, Green, and Blue channels
redChannel = originalImage(:,:,1);
greenChannel = originalImage(:,:,2);
blueChannel = originalImage(:,:,3);
% Define parameters for encryption
seed = 466; % Seed value for PRNG
M = 167;    % Multiplier (Maddy Constant)
I = pi;     % Non-integral positive value
m = 266;    % Moduli (e.g., 266)
% Define BBS parameters
bbsSeed = 123; % Seed for BBS generator
p = 383; % First large prime number
q = 503; % Second large prime number
n = p * q; % Modulus for BBS
% Perform encryption only on the red channel
[EncryptedRedChannel, FinalEncryptedRedChannel] = functionalBasedEncryption(redChannel, seed, M, I, m, bbsSeed, n);
% Reconstruct the image with the encrypted red channel
bbsEncryptedImage = originalImage; % Copy the original image
bbsEncryptedImage(:,:,1) = uint8(FinalEncryptedRedChannel); % Replace red channel
% Display the red, green, and blue channels
figure;
subplot(2, 3, 1); imshow(cat(3, redChannel, zeros(size(redChannel)), zeros(size(redChannel)))); title('Only Red');
subplot(2, 3, 2); imshow(cat(3, zeros(size(greenChannel)), greenChannel, zeros(size(greenChannel)))); title('Only Green');
subplot(2, 3, 3); imshow(cat(3, zeros(size(blueChannel)), zeros(size(blueChannel)), blueChannel)); title('Only Blue');
subplot(2, 3, 4); imshow(redChannel); title('Red Channel');
subplot(2, 3, 5); imshow(greenChannel); title('Green Channel');
subplot(2, 3, 6); imshow(blueChannel); title('Blue Channel');
% Display the final encrypted images
figure;
subplot(3, 1, 1); imshow(uint8(EncryptedRedChannel)); title('XOR Red Channel');
subplot(3, 1, 2); imshow(uint8(FinalEncryptedRedChannel)); title('BBS Encrypted Red Channel');
subplot(3, 1, 3); imshow(bbsEncryptedImage); title('Final Encrypted Image');
disp('Encryption of the red channel completed.');
%Display the histogram of the original red channel
figure;
subplot(2,1,1);
imhist(redChannel);
title('Histogram of Original Red Channel');
subplot(2,1,2);
imhist(EncryptedRedChannel);
title('Histogram of Encrypted Red Channel');
% **Decryption Steps**
% Generate the BBS sequence for decryption
bbsSequence = generate_bbs(bbsSeed, n, numel(redChannel));
bbsSequenceReshaped = reshape(bbsSequence, size(FinalEncryptedRedChannel));
% Decrypt BBS: Subtract BBS sequence modulo 256
bbsDecryptedRed = mod(double(FinalEncryptedRedChannel) - bbsSequenceReshaped, 256);
% Generate PRNG sequence for XOR decryption
prngSequence = KM_Generator(seed, M, I, m, numel(redChannel));
prngSequenceReshaped = reshape(prngSequence, size(bbsDecryptedRed));
% Decrypt XOR: Apply XOR again with the PRNG sequence
finalDecryptedRed = bitxor(uint8(bbsDecryptedRed), uint8(prngSequenceReshaped));
% Reconstruct images for display
bbsDecryptedImage = originalImage;
bbsDecryptedImage(:,:,1) = uint8(bbsDecryptedRed); % Replace red channel with BBS-decrypted data
finalDecryptedImage = originalImage;
finalDecryptedImage(:,:,1) = uint8(finalDecryptedRed); % Replace with fully decrypted red channel
% Display the decrypted images
figure;
subplot(1, 2, 1);
imshow(uint8(bbsDecryptedImage));
title('BBS Decrypted Image');
subplot(1, 2, 2);
imshow(uint8(finalDecryptedImage));
title('Final Decrypted Image');
disp('Decryption completed.');
