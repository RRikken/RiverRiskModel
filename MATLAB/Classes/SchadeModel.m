classdef SchadeModel
    %SCHADEMODEL Dit model berekend de overstromingsschade in een dijkringgebied
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function FloodDamage = CalculateFloodDamage(obj)
            %FloodDamage = sum(Alphai * NumberOfUnitsi * MaximumDamagePerUniti);
        end
        
        function DamageFactorAgricultureRecreationAirports = CalculateDamageFactorForAgricultureRecraetionAirports(obj, FloodDepth)
            DamageFactorAgricultureRecreationAirports = min([FloodDepth, 0.24 * FloodDepth + 0.4, 0.07 * FloodDepth + 0.75, 1]);
        end
        
        function DamageFactorPumpingStations = CalculateDamageFactorForPumpingStations(obj, FloodDepth)
            DamageFactorPumpingStations = min([0.9 * FloodDepth, 0.26 * FloodDepth + 0.28, 1]);
        end
        
        function DamageFactorVehicles = CalculateDamageFactorForVehicles(obj, FloodDepth)
            DamageFactorVehicles = min([0.17 * FloodDepth - 0.03, 0.72 * FloodDepth -0.3, 0.31 * FloodDepth + 0.1, 1]);
        end
        
        function DamageFactorRoadAndRailways = CalculateDamageFactorRoadRailways(obj, FloodDepth)
            DamageFactorRoadAndRailways = min([0.28 * FloodDepth, 0.18 * FloodDepth + 0.1, 1]);
        end
        
        function DamageFactorMainsGasWater = CalculateDamageGasWaterMains(obj, FloodDepth)
            DamageFactorMainsGasWater = min([0.8 * FloodDepth, 0.23 * FloodDepth + 0.18, 0.10 * FloodDepth + 0.52, 1]);
        end
        
        function DamageFactorElectricityCommunication = CalculateDamageFactorElectricityCommunication(obj, FloodDepth)
            DamageFactorElectricityCommunication = min([0.8 * FloodDepth, 0.34 * FloodDepth + 0.15, 1]);
        end
        
        function DamageFactorCompanies = CalculateDamageFactorCompanies(obj, FloodDepth)
            if FloodDepth  <= 0.1
                DamageFactorCompanies = 0.1 * FloodDepth;
            elseif FloodDepth > 0.1 && FloodDepth <= 1.3
                DamageFactorCompanies = 0.06 * FloodDepth + 0.04;
            elseif FloodDepth > 1.3 && FloodDepth <= 3.5
                DamageFactorCompanies = 0.39 * FloodDepth - 0.95;
            elseif FloodDepth > 5
                DamageFactorCompanies = 1;
            else
                debug;
            end
        end
        
        function InboedelSchade = BOERTIEN_inboedels(d,u,w,r,s,ukr)
            if d <= 0
                rs = 0;
            elseif d >= 5
                rs = 1;
            elseif u > 0.25*ukr
                rs = 1;
            else
                if s ~=  0 %(s<>0){storm}
                    p = 0.8E-3 * d^1.8 * r;
                else
                    p =  0;
                end
                if d <= 1
                    s1 = -0.470 * d^2 + 0.940*d; % 0,1
                elseif d <= 2
                    s1 = 0.030 * d + 0.44; %1,2
                elseif d <= 4
                    s1 = 0.005 * d^2 + 0.135 * d + 0.21; %2,4
                else
                    s1 = -0.170 * d^2 + 1.700 * d - 3.25; %4,5
                end
                rs = max([0,min([1, s1]) ]);
                rs = p * 1 + (1 - p) * rs;
            end
            InboedelSchade = max([0, min([1, rs]) ]);
        end
        
        function OpstalSchade = BOERTIEN_opstal(d,u,w,r,s,ukr)
            if d <= 0
                rs = 0;
            elseif d >= 5
                rs = 1;
            elseif u > 0.25 * ukr
                rs = 1;
            else
                if  s ~= 0 %(s<>0){storm}
                    p =  0.8E-3 * d^1.8 * r;
                else
                    p = 0;
                end
                if d < 2
                    s1 = 0.005 * d^2 + 0.045*d; %0,2
                elseif d<4
                    s1 = 0.045 * d^2 + 0.015 * d - 0.1; %2,4
                else
                    s1 = -0.32  * d^2 + 3.2 *d - 7;  %4,5
                end
                rs = max(0,min(1,s1));
                rs = p*1+(1-p)*rs;
            end
            OpstalSchade = max([0, min([1, rs]) ]);
        end
        
        function SchadeEensgezinswoningenEnBoerderijen = SSM_EengezinswoningenEnBoerderijen(d,u,w,r,s,ukr)
            f = 215500 / 315500;
            SchadeEensgezinswoningenEnBoerderijen = f * BOERTIEN_opstal(d,u,w,r,s,ukr) + (1 - f) * BOERTIEN_inboedels(d,u,w,r,s,ukr);
        end
        
        function DamageFactorLowRise = CalculateDamageLowRise(d, u, ukr, r)
            if d <= 0
                alpha = 0;
            elseif u > 0.25 * ukr
                alpha = 1;
            elseif s ~= 0 %s <> 0 {ja} then begin
                P = (0.8E-3 * d^1.8 * r );
            else
                P = 0;
            end
            s1 = P + (1 - P) * (1 - (1 - max([ 0, min([ d, 6 ]) ]) / 6 )^4 );
            alpha = max([0, min([1, s1]) ]);
            DamageFactorLowRise =  alpha;
        end
        
        function DamageFactorMediumRise = CalculateDamageFactorMediumRise(d, u, ukr, r)
            if d <= 0
                alpha = 0;
                if u > ukr
                    alpha = 1;
                elseif s ~= 0
                    P = 0.8E-3 * d^1.8 * r;  %Something might be wrong. '> 0.5' was added to the end of the sourcefile;
                else
                    P = 0;
                end
                s1 = P + (1 - P) * (1 - (1 - max([0,min([ d, 12 ]) /12 ]))^4);
                alpha = max([0, min([1, s1]) ]);
                DamageFactorMediumRise = alpha;
            end
        end
        
        function DamageFactorHighRise = CalaculateDamgaFactorHighRise(d, u, ukr, r)
            if d <= 0
                alpha = 0;
            elseif u > ukr
                alpha = 1;
            elseif s ~=  0
                P = 0.4E-3 * d^1.8 * r;
            else
                P = 0;
            end
            s1 = P + (1 - P) * (1 - (1 - max([0,min([ d, 18 ]) ]) / 18 )^4 );
            alpha = max([ 0 , min([1, s1]) ]);
            DamageFactorHighRise = alpha;
        end
    end
end