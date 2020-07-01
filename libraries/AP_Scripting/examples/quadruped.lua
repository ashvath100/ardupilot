-- quadruped robot script 
local flipflop = true 

k_throttle = 70
k_steering = 26

L = 80  -- length of frame
W = 80  -- width of frame 

L_COXA = 30 --distance from coxa servo to femur servo
L_FEMUR = 60    --distance from femur servo to tibia servo
L_TIBIA = 140   --distance from tibia servo to foot

--body position and rotation parameters
bodyRotX = 0
bodyRotY = 0         
bodyRotZ = 0    
bodyPosX = 0     
bodyPosY = 0            
bodyPosZ = 0

-- starting positions of the legs
endpoints1 = {math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints2 = {math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(-45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints3 = {-math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(-45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints4 = {-math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }

GaitType = 0 --select a gait pattern(default gait = 0)
LegLiftHeight = 50  --lift height while walking 
GaitStep = 0    --gait step in exectution 
GaitLegNr = {0,0,0,0}   --initial position of the leg
TLDivFactor = 0       
NrLiftedPos = 0    
LiftDivFactor = 0    
HalfLiftHeigth = 0     
FrontDownPos = 0			
TravelRequest = false        
StepsInGait = 0  --Number of steps in gait    
GaitStep = 0         
GaitPosX = {0,0,0,0}         
GaitPosY = {0,0,0,0}            
GaitPosZ = {0,0,0,0}             
GaitRotZ = {0,0,0,0}      
LegIndex = 0   
Walking = false
X_SPEED = 0
Yaw_speed = 
0
Y_SPEED = 0
DeadZone = 4

function Gaitselect()
    if (GaitType == 0) then
        GaitLegNr = {1,4,1,4}
        NrLiftedPos = 2
        FrontDownPos = 1	
        LiftDivFactor = 2
        HalfLiftHeigth = 1
        TLDivFactor = 4   
        StepsInGait = 6     
    end 
end

function Seq()
    TravelRequest =(math.abs(X_SPEED) > DeadZone) or (math.abs(Y_SPEED) > DeadZone) or (math.abs(Yaw_speed) > DeadZone) 
    
    if TravelRequest then
        for LegIndex=1,4,1 
        do 
            Gaitgen(LegIndex)
    end

    GaitStep = GaitStep + 1
    if (GaitStep>StepsInGait) then
        GaitStep = 1
        
    end 
    
end

end

function Gaitgen(Gaitcurrent)
    local LegStep = GaitStep - GaitLegNr[Gaitcurrent]

    if ((TravelRequest and (NrLiftedPos and 1) and 
    LegStep==0) or 
    (not TravelRequest and LegStep==0 and ((GaitPosX[Gaitcurrent]>2) or 
    (GaitPosZ[Gaitcurrent]>2) or (GaitRotZ[Gaitcurrent] >2)))) 
    then
        GaitPosX[Gaitcurrent] = 0
        GaitPosZ[Gaitcurrent] = -LegLiftHeight
        GaitPosY[Gaitcurrent] = 0
        GaitRotZ[Gaitcurrent] = 0

    elseif (((NrLiftedPos==2 and LegStep==0) or (NrLiftedPos>=3 and 
    (LegStep==-1 or LegStep==(StepsInGait-1))))
    and TravelRequest)
    then
        GaitPosX[Gaitcurrent] = -X_SPEED/LiftDivFactor
        GaitPosZ[Gaitcurrent] = -3*LegLiftHeight/(3+HalfLiftHeigth)  
        GaitPosY[Gaitcurrent] = -Y_SPEED/LiftDivFactor
        GaitRotZ[Gaitcurrent] = -Yaw_speed/LiftDivFactor

    elseif ((NrLiftedPos>=2) and (LegStep==1 or LegStep==-(StepsInGait-1)) and TravelRequest)
    then
        GaitPosX[Gaitcurrent] = X_SPEED/LiftDivFactor
        GaitPosZ[Gaitcurrent] = -3*LegLiftHeight/(3+HalfLiftHeigth)  
        GaitPosY[Gaitcurrent] = Y_SPEED/LiftDivFactor
        GaitRotZ[Gaitcurrent] = Yaw_speed/LiftDivFactor

    elseif (((NrLiftedPos==5 and (LegStep==-2 ))) and TravelRequest)
    then
        GaitPosX[Gaitcurrent] = -X_SPEED/2
        GaitPosZ[Gaitcurrent] = -LegLiftHeight/2 
        GaitPosY[Gaitcurrent] = -Y_SPEED/2
        GaitRotZ[Gaitcurrent] = -Yaw_speed/2

    elseif ((NrLiftedPos==5) and (LegStep==2 or LegStep==-(StepsInGait-2)) and TravelRequest)
    then
        GaitPosX[Gaitcurrent] = X_SPEED/2
        GaitPosZ[Gaitcurrent] = -LegLiftHeight/2 
        GaitPosY[Gaitcurrent] = Y_SPEED/2
        GaitRotZ[Gaitcurrent] = Yaw_speed/2

    elseif ((LegStep==FrontDownPos or LegStep==-(StepsInGait-FrontDownPos)) and GaitPosY[Gaitcurrent]<0)
    then
        GaitPosX[Gaitcurrent] = X_SPEED/2
        GaitPosZ[Gaitcurrent] = Y_SPEED/2
        GaitPosY[Gaitcurrent] = Yaw_speed/2   
        GaitRotZ[Gaitcurrent] = 0

    else 
        GaitPosX[Gaitcurrent] = GaitPosX[Gaitcurrent] - (X_SPEED/TLDivFactor)
        GaitPosZ[Gaitcurrent] = 0
        GaitPosY[Gaitcurrent] = GaitPosZ[Gaitcurrent] - (Y_SPEED/TLDivFactor)
        GaitRotZ[Gaitcurrent] = GaitRotZ[Gaitcurrent] - (Yaw_speed/TLDivFactor)
    end
end

function bodyik(X , Y , Z,   Xdist, Ydist,Zrot)
    local totaldist = { X + Xdist + bodyPosX, Y + Ydist + bodyPosY }
    local distBodyCenterFeet = math.sqrt(totaldist[1]^2 + totaldist[2]^2)
    local AngleBodyCenter = math.atan(totaldist[2], totaldist[1])
    local rolly = math.tan(bodyRotY * math.pi/180) * totaldist[1]
    local pitchy = math.tan(bodyRotX * math.pi/180) * totaldist[2]

    local ansx = math.cos(AngleBodyCenter + ((bodyRotZ+Zrot)  * math.pi/180)) * distBodyCenterFeet - totaldist[1] + bodyPosX
    local ansy = math.sin(AngleBodyCenter + ((bodyRotZ+Zrot) * math.pi/180)) * distBodyCenterFeet - totaldist[2] + bodyPosY
    local ansz = rolly+pitchy + bodyPosZ
    local ans = {ansx, ansy ,ansz}
    return ans 
end 

function legik(X , Y , Z)
    local coxa = math.atan(Y,X) 
    local trueX = math.sqrt(X^2+ Y^2 ) - L_COXA
    local IKSW = math.sqrt(trueX^2 + Z^2)

    local IKA1 = math.atan(trueX / Z)
    local d1 = L_TIBIA^2 - L_FEMUR^2 - IKSW^2
    local d2 = -2*L_FEMUR*IKSW
    local IKA2 = math.acos(d1/d2)
    local femur = 1.5708-(IKA1+IKA2)

    local d1 = IKSW^2 - L_TIBIA^2 - L_FEMUR^2
    local d2 = -2*IKSW*L_FEMUR
    local tibia = 1.5708-(math.acos(d1/d2)) 
    local ang = { coxa, femur ,tibia }
    return ang 
end
    

function doik()
    Gaitselect()
    Seq()
    local ans1 = bodyik(endpoints1[1]+GaitPosX[1], endpoints1[2]+GaitPosY[1], endpoints1[3]+GaitPosZ[1], L/2, W/2,GaitRotZ[1])
    local angles1 = legik(endpoints1[1]+ans1[1]+GaitPosX[1],endpoints1[2]+ans1[2]+GaitPosY[1], endpoints1[3]+ans1[3]+GaitPosZ[1])
    angles1 = {-0.785398 + angles1[1],angles1[2],angles1[3]}

    local ans2 = bodyik(endpoints2[1]+GaitPosX[2], endpoints2[2]+GaitPosY[2], endpoints2[3]+GaitPosZ[2], L/2, -W/2,GaitRotZ[2])
    local angles2 = legik(endpoints2[1]+ans2[1]+GaitPosX[2],endpoints2[2]+ans2[2]+GaitPosY[2], endpoints2[3]+ans2[3]+GaitPosZ[2])
    angles2 = {0.785398 + angles2[1],angles2[2],angles2[3]}

    local ans3 = bodyik(endpoints3[1]+GaitPosX[3], endpoints3[2]+GaitPosY[3], endpoints3[3]+GaitPosZ[3], -L/2, -W/2,GaitRotZ[3])
    local angles3 = legik(endpoints3[1]+ans3[1]+GaitPosX[3],endpoints3[2]+ans3[2]+GaitPosY[3], endpoints3[3]+ans3[3]+GaitPosZ[3])
    angles3 = {2.35619 + angles3[1],angles3[2],angles3[3]}

    local ans4 = bodyik(endpoints4[1]+GaitPosX[4], endpoints4[2]+GaitPosY[4], endpoints4[3]+GaitPosZ[4], -L/2, W/2,GaitRotZ[4])
    local angles4 = legik(endpoints4[1]+ans4[1]+GaitPosX[4],endpoints4[2]+ans4[2]+GaitPosY[4], endpoints4[3]+ans4[3]+GaitPosZ[4])
    angles4 = {-2.35619 + angles4[1],angles4[2],angles4[3]}

    return angles1,angles4,angles3,angles2
end 


pwm = { 1500, 1500, 1500,
        1500, 1500, 1500,
        1500, 1500, 1500,
        1500, 1500, 1500 }

local angle = 0.0


function update()
X_SPEED = SRV_Channels:get_output_scaled(k_throttle) * 0.3
Yaw_speed = SRV_Channels:get_output_scaled(k_steering) * 0.003
FR_angles ,  BL_angles, BR_angles, FL_angles = doik()
angles ={FL_angles[1],FL_angles[2],FL_angles[3],FR_angles[1],FR_angles[2],FR_angles[3],BL_angles[1],BL_angles[2],BL_angles[3],BR_angles[1],BR_angles[2],BR_angles[3]}

    for j = 1, 12 do
        pwm[j] = math.floor(((angles[j] * 100)/51 * 100) + 1500)
    end

    for i = 1, 12 do
        SRV_Channels:set_output_pwm_chan_timeout(i-1, pwm[i], 1000)
    end
    return update, 340
end

gcs:send_text(0, "quadruped")
return update()
