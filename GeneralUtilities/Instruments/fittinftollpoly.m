
x = x(:);
y=y(:);
% --- Create fit "fit 2"
ok_ = isfinite(x) & isfinite(y);
ft_ = fittype('poly2');

% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_);

ci = confint(cf_ ,0.95);

[p,S] = polyfit(x,y,3);
[y_fit delta]= polyval(p ,x ,S);
