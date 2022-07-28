function curvedistance = signalseparation6g(ng1, ng2, ng3, ng4, ng5,ng6,examplecurve, coeffs)

% coeffs(coeffs<0)=0;
% coeffs(coeffs>1)=1;

G1_coeff = coeffs(1);
G2_coeff = coeffs(2);
G3_coeff = coeffs(3);
G4_coeff = coeffs(4);
G5_coeff = coeffs(5);

G6_coeff = 1 - coeffs(1) - coeffs(2) - coeffs(3) - coeffs(4) - coeffs(5);


examplecurve = examplecurve / max(examplecurve);

combined_curve =G1_coeff * ng1 + G2_coeff * ng2 + G3_coeff * ng3 + G4_coeff * ng4+ G5_coeff * ng5 + G6_coeff * ng6;

curve_difference = abs(combined_curve - examplecurve);
curvedistance = sqrt(mean(curve_difference.^2));