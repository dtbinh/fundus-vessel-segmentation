% Select features
function [features] = features_prompt(prompt)
    % Initialize the binary array to be returned
    features = zeros(16,1);
    % Prepare the prompt string
    prompt = strcat(prompt, '\n');
    prompt = strcat(prompt, 'Select features to include (number separated with comma):\n');
    prompt = strcat(prompt, '1. Matched filter responses (Al-Rawi et al, 2007) \n');
    prompt = strcat(prompt, '2. Vesselness measure (Frangi et al, 1998) \n');
    prompt = strcat(prompt, '3. Multiscale Gabor wavelets (Soares et al, 2006) \n');
    prompt = strcat(prompt, '4. Morphological operations (Zana et al, 2001) \n');
    prompt = strcat(prompt, '5. Multiscale line detectors (Nguyen et al, 2012) \n');
    prompt = strcat(prompt, '6. Line detectors (Ricci et al, 2007) \n');
    prompt = strcat(prompt, '7. Module of the 1st order gradient \n');
    prompt = strcat(prompt, '8. Intensities \n');
    prompt = strcat(prompt, '9. Ridge detectors over scales (Martinez-Perez et al, 2007) \n');
    prompt = strcat(prompt, '10. (x,y) coordinates \n');
    prompt = strcat(prompt, '11. Vessel enhancement procedure (Marin et al, 2011) \n');
    prompt = strcat(prompt, '12. Huffman''s entropy over scales \n');
    prompt = strcat(prompt, '13. Direction of the 1st order gradient \n');
    prompt = strcat(prompt, '14. Max value of ridge detectors over scales (Martinez-Perez et al, 2007) \n');
    prompt = strcat(prompt, '15. Vessel enhancement procedure (Sinthanayothin et al, 1999) \n');
    prompt = strcat(prompt, '16. Vessel enhancement procedure (Saleh et al, 2013) \n');
    % Get a string containing indices
    featindices = input(prompt, 's');
    % Set ones where it corresponds
    C = strsplit(strtrim(featindices),',');
    for i = 1 : length(C)
        features(str2num(C{i})) = 1;
    end
end