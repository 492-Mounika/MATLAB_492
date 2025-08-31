%% Wireless Image Transmission using MATLAB

% Step 1: Load & preprocess image
img = imread('cameraman.tif');   % built-in image
img_resized = imresize(img, [128 128]);

% Convert to bitstream
img_bin = de2bi(img_resized(:), 8, 'left-msb');
bitstream = img_bin(:);

% Step 2: Modulation
M = 4; 
symbols = bi2de(reshape(bitstream, log2(M), []).','left-msb'); 
tx_sig = pskmod(symbols, M, pi/4);

% Step 3: Wireless channel simulation
SNR_dB = 0:5:30;   
ber = zeros(size(SNR_dB));  

for i = 1:length(SNR_dB)
    rx_sig = awgn(tx_sig, SNR_dB(i), 'measured');
    
    % Step 4: Demodulation & bit recovery
    rx_sym = pskdemod(rx_sig, M, pi/4);
    rx_bits = de2bi(rx_sym, log2(M), 'left-msb');
    rx_bitstream = rx_bits(:);
    
    % BER calculation
    [~, ber(i)] = biterr(bitstream, rx_bitstream);
    
    % Reconstruct image
    rx_pixels = bi2de(reshape(rx_bitstream, 8, []).','left-msb');
    rx_img = reshape(uint8(rx_pixels), size(img_resized));
    
    if i == 1
        figure; imshow(rx_img); 
        title(['Received Image at SNR = ', num2str(SNR_dB(i)), ' dB']);
    end
end

% Step 5: Plot BER vs SNR
figure; semilogy(SNR_dB, ber, '-o');
xlabel('SNR (dB)'); ylabel('Bit Error Rate');
title('BER vs SNR for QPSK Image Transmission');
grid on;

% Final comparison
figure;
subplot(1,2,1); imshow(img_resized); title('Original Image');
subplot(1,2,2); imshow(rx_img); title(['Received Image at ', num2str(SNR_dB(end)), ' dB']);
