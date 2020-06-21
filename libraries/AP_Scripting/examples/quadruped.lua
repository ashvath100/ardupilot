local flipflop = true
k_throttle = 70
L = 80 
W = 80 
L_COXA = 30 
L_FEMUR = 60 
L_TIBIA = 140

bodyRotX = 0
bodyRotY = 0         
bodyRotZ = 0    
bodyPosX = 0     
bodyPosY = 0            
bodyPosZ = 0

endpoints1 = {math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints2 = {math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(-45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints3 = {-math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(-45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }
endpoints4 = {-math.cos(45/180*math.pi)*(L_COXA + L_FEMUR), math.sin(45/180*math.pi)*(L_COXA + L_FEMUR),      L_TIBIA }

function bodyik(X , Y , Z,   Xdist, Ydist)
    local totaldist = { X + Xdist + bodyPosX, Y + Ydist + bodyPosY }
    local distBodyCenterFeet = math.sqrt(totaldist[1]^2 + totaldist[2]^2)
    local AngleBodyCenter = math.atan(totaldist[2], totaldist[1])
    local rolly = math.tan(bodyRotY * math.pi/180) * totaldist[1]
    local pitchy = math.tan(bodyRotX * math.pi/180) * totaldist[2]

    local ansx = math.cos(AngleBodyCenter + (bodyRotZ * math.pi/180)) * distBodyCenterFeet - totaldist[1] + bodyPosX
    local ansy = math.sin(AngleBodyCenter + (bodyRotZ * math.pi/180)) * distBodyCenterFeet - totaldist[2] + bodyPosY
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
    local ans1 = bodyik(endpoints1[1], endpoints1[2], endpoints1[3], L/2, W/2)
    local angles1 = legik(endpoints1[1]+ans1[1],endpoints1[2]+ans1[2], endpoints1[3]+ans1[3])
    angles1 = {-0.785398 + angles1[1],angles1[2],angles1[3]}

    local ans2 = bodyik(endpoints2[1], endpoints2[2], endpoints2[3], L/2, -W/2)
    local angles2 = legik(endpoints2[1]+ans2[1],endpoints2[2]+ans2[2], endpoints2[3]+ans2[3])
    angles2 = {0.785398 + angles2[1],angles2[2],angles2[3]}

    local ans3 = bodyik(endpoints3[1], endpoints3[2], endpoints3[3], -L/2, -W/2)
    local angles3 = legik(endpoints3[1]+ans3[1],endpoints3[2]+ans3[2], endpoints3[3]+ans3[3])
    angles3 = {2.35619 + angles3[1],angles3[2],angles3[3]}

    local ans4 = bodyik(endpoints4[1], endpoints4[2], endpoints4[3], -L/2, W/2)
    local angles4 = legik(endpoints4[1]+ans4[1],endpoints4[2]+ans4[2], endpoints4[3]+ans4[3])
    angles4 = {-2.35619 + angles4[1],angles4[2],angles4[3]}

    return angles1,angles4,angles3,angles2
end 


pwm = { 1500, 1500, 1500,
        1500, 1500, 1500,
        1500, 1500, 1500,
        1500, 1500, 1500 }

local angle = 0.0


function update()
local t = 0.001 * millis():tofloat()
local angle = math.sin(t)
bodyPosX = math.floor(angle*20)
bodyPosZ = SRV_Channels:get_output_scaled(k_throttle) * 0.2


FR_angles ,  BL_angles, BR_angles, FL_angles = doik()

angles ={FL_angles[1],FL_angles[2],FL_angles[3],FR_angles[1],FR_angles[2],FR_angles[3],BL_angles[1],BL_angles[2],BL_angles[3],BR_angles[1],BR_angles[2],BR_angles[3]}

    for j = 1, 12 do
        pwm[j] = math.floor(((angles[j] * 100)/51 * 100) + 1500)
    end

    for i = 1, 12 do
        SRV_Channels:set_output_pwm_chan_timeout(i-1, pwm[i], 1000)
    end
    return update, 200
end

gcs:send_text(0, "quadruped")
return update, 1000
