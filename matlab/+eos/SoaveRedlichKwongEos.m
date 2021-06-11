classdef SoaveRedlichKwongEos < eos.CubicEosBase
    properties (SetAccess = private)
        AcentricFactor
    end
    methods
        function obj = SoaveRedlichKwongEos(Pc,Tc,omega)
            % Pc : Critical pressure
            % Tc : Critical temperature
            % omega : Acentric factor
            obj@eos.CubicEosBase(0.42748,0.08664,Pc,Tc)
            obj.AcentricFactor = omega;
        end
    end
    methods (Static)
        function coeffs = zFactorCubicEq(A,B)
            % Computes coefficients of Z-factor cubic equation
            % A : Reduced attraction parameter
            % B : Reduced repulsion parameter
            coeffs = [1, -1, A - B - B^2, -A*B];
        end
        function lnPhi = lnFugacityCoeff(z,A,B)
            % Computes natural log of fugacity coefficients
            %
            % Parameters
            % ----------
            % z : Z-factor
            % A : Reduced attraction parameter
            % B : Reduced repulsion parameter
            %
            % Returns
            % -------
            % lnPhi : Natural log of fugacity coefficients
            lnPhi = z - 1 - log(z - B) - A/B*log(B./z + 1);
        end
        function phi = fugacityCoeff(z,A,B)
            % Computes fugacity coefficients
            %
            % Parameters
            % ----------
            % z : Z-factor
            % A : Reduced attraction parameter
            % B : Reduced repulsion parameter
            %
            % Returns
            % -------
            % phi : Fugacity coefficients
            phi = exp(eos.SoaveRedlichKwongEos.lnFugacityCoeff(z,A,B));
        end
    end
    methods
        function obj = setCriticalProperties(obj,Pc,Tc,omega)
            obj = setCriticalProperties@eos.CubicEosBase(obj,Pc,Tc);
            obj.AcentricFactor = omega;
        end
        function alpha = temperatureCorrectionFactor(obj,Tr)
            % Computes temperature correction factor for attraction parameter
            %
            % Parameters
            % ----------
            % Tr : Reduced temperature
            %
            % Returns
            % -------
            % alpha : Temperature correction factor
            omega = obj.AcentricFactor;
            m = 0.48 + 1.574*omega - 0.176*omega^2;
            alpha = (1 + m*(1 - sqrt(Tr)))^2;
        end
        function P = pressure(obj,T,V)
            % Computes pressure
            %
            % Parameters
            % ----------
            % T : Temperature
            % V : Volume
            %
            % Returns
            % -------
            % P : Pressure
            Tr = obj.reducedTemperature(T);
            alpha = obj.temperatureCorrectionFactor(Tr);
            a = obj.AttractionParam;
            b = obj.RepulsionParam;
            R = eos.ThermodynamicConstants.Gas;
            P = R*T./(V - b) - alpha*a./(V.*(V + b));
        end
        function [z,A,B] = zFactors(obj,P,T)
            % Computes Z-factors
            %
            % Parameters
            % ----------
            % P : Pressure
            % T : Temperature
            %
            % Returns
            % -------
            % z : Z-factors
            % A : Reduced attraction parameter
            % B : Reduced repulsion parameter
            Pr = obj.reducedPressure(P);
            Tr = obj.reducedTemperature(T);
            alpha = obj.temperatureCorrectionFactor(Tr);
            A = obj.reducedAttractionParam(Pr,Tr,alpha);
            B = obj.reducedRepulsionParam(Pr,Tr);
            x = roots(eos.SoaveRedlichKwongEos.zFactorCubicEq(A,B));
            z = x(imag(x) == 0);
        end
    end
end