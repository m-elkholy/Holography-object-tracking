%Plot Absolute Speed Histogram and Plot turn angles histogram
clearvars mag true_mag
mag= sqrt(u(:).^2+v(:).^2+w(:).^2);
j =1;
for i = 1:size(mag,1)
    if isnan(mag(i))==0
        true_mag(j) = mag(i);
        j = j+1;
    end
end

histogram(true_mag,100)