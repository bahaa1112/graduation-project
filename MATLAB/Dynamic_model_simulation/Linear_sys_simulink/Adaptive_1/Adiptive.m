function dz = Adiptive(t,z,A,B,K,r,Am,Bm,p,basis_fun,weights,d,Km)
    n = 10;  % Number of states
    m = 5;   % Number of inputs

    x  = z(1:n);                 
    xm = z(n+1:2*n);             
    omega_hat = reshape(z(2*n+1:end), n, m); 

    % Tracking error
    e = x - xm;

    % Basis function at current time
    beta = basis_fun(t); 

    % Adaptive law (MRAC)
    gamma = 10*eye(n);
    
     omega_hat_dot = -gamma * beta * (e'*p*B); 
     %omega_hat_dot = -gamma * (beta * (e'*p*B)+ sigma * omega_hat);
    % Adaptive control input
    u_ad = omega_hat.' * beta; 
    u = -K*x + r - u_ad;

    % Uncertainty
    delta_X = weights * beta; 
    


    % Real system dynamics
    dx = A*x + B*(u + delta_X) + d;

    % Reference model dynamics
    dxm = Am*xm + Bm*(-Km*xm + r);
    
 

    % Combine dz
    dz = zeros(2*n + n*m,1);
    dz(1:n)       = dx;
    dz(n+1:2*n)   = dxm;
    dz(2*n+1:end) = omega_hat_dot(:); 
end