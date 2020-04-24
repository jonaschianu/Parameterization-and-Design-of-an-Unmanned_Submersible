%This function is the main "design" function.

function Design_code(depth,Occupants,Material)
    %Check if the user tries to run this file directly
    
    if ~exist('depth','var')
        cd Z:\SUB-1A\MATLAB\
        run Z:\SUB-1A\MATLAB\MAIN.m; %Run Main.m instead
        
        return
    end

    %DESIGN CALCULATIONS done here. Feel free to use as many subfunctions as necessary.
    
    gravity= 9.81; %Units (m/s^2)
    
    [density_metal, yield_metal]=get_Metal_properties(Material); %A call to a subfunction to calculate the density and yield strength of selected metal
    
    density_water=1029; %Units (kg/m^3). The desity of sea water G. Elert, “Density of Seawater,” Density of Seawater - The Physics Factbook. [Online]. Available: https://hypertextbook.com/facts/2002/EdwardLaValley.shtml. [Accessed: 09-Nov-2019].
    
    %Pressure Values
    inner_pressure= 101325; %Units (Pa). It is equal to atmospheric pressure
    outer_pressure=density_water*gravity*depth+inner_pressure; %Units (Pa)
    
    %Hull Properties
    density_acryllic=1180; %Units (kg/m^3). The extruded Acrylic density Density of Selected Solids,” Engineering ToolBox. [Online]. Available: https://www.engineeringtoolbox.com/density-solids-d_1265.html. [Accessed: 18-Nov-2019]
    strength_acryllic = 70e+06; %Units (Pa). Acrylic yield stress, Engineering Toolbox. [Online]. Available: https://www.engineeringtoolbox.com/young-modulus-d_417.html. [Accessed Oct. 9th,2019]
    
    inner_diameter = calc_inner_diameter(Occupants); %Units (m). A call to a subfunction to choose inner diameter
    outer_diameter = calc_outer_diameter(strength_acryllic, inner_diameter, inner_pressure, outer_pressure); %Units (m). A call to a subfunction to calculate outer diameter
    
    Hull_Volume=((4/3)*(1/8))*pi*(outer_diameter^3-inner_diameter^3); %Units (m^3)
    Hull_Submerged_Volume=((4/3)*(1/8))*pi*(outer_diameter^3); %Units (m^3)
    
    Hull_Mass=Hull_Volume*density_acryllic; %Units (kg)
    
    %Hatch Dimensions
    radius_hatch_door=0.275; %Units (m). radius of hatch door
    thickness_hatch_door=calc_hatch_door(inner_pressure, outer_pressure,radius_hatch_door,yield_metal); %Units (m). A call to a subfunction to calculate the hatch door thickness
    
    Hatch_Mass=(40.5938*(thickness_hatch_door/0.01)+419.58315)*(yield_metal/290e+06); %Units (kg). Mass of hatch assembly
    mass_hatch_door=40.5938*(thickness_hatch_door/0.01)+26.6957; %Units (kg)
    
    %Hatch door-spring Dimensions
    radius_hatchdoor_to_spring=0.365; %Units (m)
    rod_dia=0.040; %Units (m). Diameter of the rod that rod that the spring are wrapped around.
    
    num_spring=2;
    ultimate_spring=1350e06; %Units (Pa). steel ASTM A232
    spring_wire_dia=calc_spring_wire_dia(mass_hatch_door,radius_hatchdoor_to_spring, rod_dia, ultimate_spring,num_spring); %Units (m). A call to a subfunction to calculate the spring wire diameter
    
    %Frame Dimensions. Calculation using Solidworks sketches and dimensions
    Bottom_Frame_Height=0.22*(depth/1000); %Units (m).
    Bottom_Frame_Length=1.24*( outer_diameter / 2.02); %Units (m).
    Side_Frame_Length=((2.25-0.37)+((1.5-0.45-0.15)^2+(0.42-0.05)^2+0.6^2)^(1/2)+0.45)*( outer_diameter / 2.02); %Units (m).
    Back_Frame_Length=1.24*( outer_diameter / 2.02)-(0.42*( outer_diameter / 2.02)-0.05)*2; %Units (m).
    Top_Frame_Length=(0.95+1.265)*( outer_diameter / 2.02); %Units (m).
    
    %Fairing Dimensions.
    Fairing_Back_Length=(0.5+0.3+((1.4-0.3)^2+0.6^2)^(1/2)+0.2); %Units (m)
    Fairing__Back_Volume=Fairing_Back_Length*(1.24*(outer_diameter/2.02)+(0.05*2))*0.005; %Units (m^3)
    
    Fairing__Cover_Side_Area=(1.4*2.4*( outer_diameter / 2.02)^2)/2; %Units (m^2)
    Fairing_Side_Perimeter=0.5+0.3+((1.4-0.3)^2+0.6^2)^(1/2)+2.4+((2.4+0.6-0.5-2.1)^2+0.54^2)^(1/2)+((1.4-0.54)^2+2.1^2)^(1/2); %Units (m)
    
    Fairing_Side_Total_Submerged_Volume=2*Fairing__Cover_Side_Area*(0.005*2+0.42*( outer_diameter / 2.02)); %Units (m^3)
    Fairing_Side_Total_Volume=(Fairing__Cover_Side_Area*0.005*2+Fairing_Side_Perimeter*0.42*( outer_diameter / 2.02)*0.005); %Units (m^3)
    Fairing_Total_Submerged_Volume=2*Fairing_Side_Total_Submerged_Volume+Fairing__Back_Volume; %Units (m^3)
    Fairing_Total_Volume=2*Fairing_Side_Total_Volume+Fairing__Back_Volume; %Units (m^3)
   
    Fairing_Mass=Fairing_Total_Volume*density_metal; %Units (kg)
    
    %Penetrator, seating, and inner assembly properties
    [platform_height, platform_diameter,platform_seating_mass,second_seat,third_seat]=calc_platform_dim(Occupants); %A call to a subfunction to choose height of platform from the bottom of hull and its diameter. Also gives mass of platform and values for number of seats.
    penetrator_Total_mass=800*(outer_diameter-inner_diameter)/(2.05-1.7); %Units (kg)
    
    %Oxygen Tank Properties
    [oxygen_tank_mass,oxygen_tank_submerged_volume]=calc_oxygen_tank_mass(Occupants); %A call to a subfunction to calculate the oxygen tank mass and submerged volume.
    
    %Compressed air tank properties
    compressed_air_mass=(20.7884*(depth/1000)^2+137.458*(depth/1000))*4; %Units (kg)
    
    compressed_air_dia=0.25*(depth/1000)^(1/2); %Units (m)
    compressed_air_height=1.2954; %Units (m)
    compressed_air_submerged_volume=4*(pi/4)*compressed_air_dia^2*compressed_air_height; %Units (m^3)
    
    %Battery Properties
    Battery_Mass=220; %Units (kg)
    
    %Total Mass and Volume without ballast and dropweight, and without frame
    %assembly
    Total_Mass_without_frame=Hull_Mass+Fairing_Mass+Battery_Mass+Hatch_Mass+oxygen_tank_mass+compressed_air_mass+penetrator_Total_mass+platform_seating_mass; %Units (kg) 
    
    Total_Submerged_Volume_without_frame=Hull_Submerged_Volume+Fairing_Total_Submerged_Volume+oxygen_tank_submerged_volume+compressed_air_submerged_volume; %Units (kg)
    Total_Submerged_Mass_without_frame=Total_Submerged_Volume_without_frame*density_water; %Units (kg)
    
    %Masses and Moment Calculations
    x=(1.265/2)*( outer_diameter / 2.02)+(0.1/2); %Units (kg). Location of point of highest stress on the top side frame starting from the lifting point towards back of the sub.
    
    [XS_width,XS_height,Total_Mass,Total_submerged_Mass]=calc_Frame_dimension(x,Total_Mass_without_frame,density_metal,yield_metal,Bottom_Frame_Length,Side_Frame_Length,Back_Frame_Length,Top_Frame_Length,Total_Submerged_Mass_without_frame,density_water,depth); %A call to a subfunction to calculate the frame cross-section width and height, Total Mass, and Total Submerged Mass
   
    %Forces
    Force_Gravity=Total_Mass*9.81; %Units (N)
    Force_Buoyancy=Total_submerged_Mass*9.81; %Units (N)
    
    %Side Frame to Side Fairing cover Connection
    fairingtoframe_num_bolt=4;
    
    fairingtoframe_bolt_dia=calc_shear_bolt_dia(Fairing_Mass,yield_metal,fairingtoframe_num_bolt, XS_width); %A call to a subfunction to calculate the bolting diameter due to shear yielding
    
    %Side Frame to Top Side Frame Bolting Connection
    Top_Frame_Volume=Top_Frame_Length*XS_height*XS_width; %Units (m^3)
    Top_Frame_Mass=Top_Frame_Volume*density_metal; %Units (kg)
    Mass_joint=(Total_Mass-Top_Frame_Mass)/2; %Units (kg). Mass/Force at the joint/connection.
    
    frametoframe_num_bolt=2;
    frametoframe_bolt_dia=calc_shear_bolt_dia(Mass_joint,yield_metal,frametoframe_num_bolt, XS_width); %A call to a subfunction to calculate the bolting diameter due to shear yielding
   
    %Ladder to Top Side Frame Bolting Connection
    Mass=300/2+26.88/2; %Units (kg). Ladder mass and mass of 3 people (extreme case) standing on a ladder, for a connection joint
    
    ladder_num_bolt=1;
    ladder_bolt_dia=calc_shear_bolt_dia(Mass,yield_metal,ladder_num_bolt, XS_width); %A call to a subfunction to calculate the bolting diameter due to shear yielding
    
    %Side Fairings to Back Fairing Bolting Connection
    Fairing_Back_Mass=Fairing__Back_Volume*density_metal; %Units (kg)
    
    fairingtofairing_num_bolt=2;
    fairingtofairing_bolt_dia=tensile_bolt_dia(Fairing_Back_Mass,yield_metal,fairingtofairing_num_bolt); %A call to a subfunction to calculate the bolting diameter due to tensile yielding
    
    %Lifting Point Length
    lifting_point_length=calc_lifting_point_length(Force_Gravity,XS_width,yield_metal); %A call to a subfunction to calculate the length of the lifting point weld and thus the length of the lifting point
    
    %Declaring text files to be modified
    %Files
    log_file = 'Z:\\SUB-1A\\Log\\groupSUB1A_LOG.TXT';
    Hull_file = 'Z:\\SUB-1A\\SolidWorks\\Equations\\Hull.txt';
    Frame_file = 'Z:\\SUB-1A\\SolidWorks\\Equations\\Frame.txt';
    Fairing_file= 'Z:\\SUB-1A\\SolidWorks\\Equations\\Fairing.txt';
    Hatch_file='Z:\\SUB-1A\\SolidWorks\\Equations\\Hatch.txt';
    Penetrator_file='Z:\\SUB-1A\\SolidWorks\\Equations\\Penetrator.txt';
        
	%Write the log file (NOT USED BY SOLIDWORKS, BUT USEFUL TO DEBUG PROGRAM AND REPORT RESULTS IN A CLEAR FORMAT)
	%Please only create one log file for the complete project but try to keep the file easy to read by adding blank lines and sections...
    fid = fopen(log_file,'w+t');
    fprintf(fid,'************************************************************************************************\n');
    fprintf(fid,'***Input Parameters***\n');
    fprintf(fid,strcat('Depth =',32,num2str(depth),' (m).\n'));
    fprintf(fid,strcat('Number of Occupants =',32,num2str(Occupants),' .\n'));
    fprintf(fid,strcat('Metal Material=',32,num2str(Material),' .\n'));
    fprintf(fid,'************************************************************************************************\n');
    fprintf(fid,'***Hull Design***\n');
    fprintf(fid,strcat('We assume that the Hull is made of acryllic.\n'));
    fprintf(fid,strcat('Inner Diameter =',32,num2str(inner_diameter),' (m).\n'));
    fprintf(fid,strcat('Outer Diameter =',32,num2str(outer_diameter),' (m).\n'));
    fprintf(fid,'************************************************************************************************\n');
    fprintf(fid,'***Submarine Dimensions***\n');
    fprintf(fid,strcat('Width=',32,num2str((0.005*2+0.42*( outer_diameter / 2.02))*2+(1.24*(outer_diameter/2.02)+(0.05*2))),' (m).\n'));
    fprintf(fid,strcat('Height =',32,num2str(outer_diameter+Bottom_Frame_Height),' (m).\n'));
    fprintf(fid,strcat('Length =',32,num2str((2.4+0.6)*(outer_diameter/2.02)),' (m).\n'));
    fprintf(fid,'************************************************************************************************\n');
    fprintf(fid,'***Mass and Forces***\n');
    fprintf(fid,strcat('Total Mass =',32,num2str(Total_Mass),' (kg).\n'));
    fprintf(fid,strcat('Gravity Force =',32,num2str(Force_Gravity),' (N).\n'));
    fprintf(fid,strcat('Buoyancy Force =',32,num2str(Force_Buoyancy),' (N).\n'));
    fprintf(fid,'************************************************************************************************\n');
	fclose(fid);

	%Write the equations file(s) (FILE(s) LINKED TO SOLIDWORKS).
	%You can make a different file for each section of your project (ie one for steering, another for brakes, etc...)
	%or one single large file that includes all the equations. Its up to you!
    %Hull File
    fid = fopen(Hull_file,'w+t');
    fprintf(fid,strcat('"Hull OD"=',num2str(outer_diameter),'\n'));
    fprintf(fid,strcat('"Hull ID"=',num2str(inner_diameter),'\n'));
    fclose(fid);
    
    %Hatch File
    fid = fopen(Hatch_file,'w+t');
    fprintf(fid,strcat('"Hull OD"=',num2str(outer_diameter),'\n'));
    fprintf(fid,strcat('"Hull ID"=',num2str(inner_diameter),'\n'));
    fprintf(fid,strcat('"Hatch Door Thickness"=',num2str(thickness_hatch_door),'\n'));
    fprintf(fid,strcat('"spring wire diameter"=',num2str(spring_wire_dia),'\n'));
    fclose(fid);
    
    %Frame File
    fid = fopen(Frame_file,'w+t');
    fprintf(fid,strcat('"Hull OD"=',num2str(outer_diameter),'\n'));
    fprintf(fid,strcat('"Bottom Frame H"=',num2str(Bottom_Frame_Height ),'\n'));
    fprintf(fid,strcat('"Bottom Frame L"=',num2str(Bottom_Frame_Length ),'\n'));
    fprintf(fid,strcat('"XS height"=',num2str(XS_height ),'\n'));
    fprintf(fid,strcat('"XS width"=',num2str(XS_width ),'\n'));
    fprintf(fid,strcat('"Fairing to Frame Bolt Diameter"=',num2str(fairingtoframe_bolt_dia ),'\n'));
    fprintf(fid,strcat('"Frame to Frame Bolt Diameter"=',num2str(frametoframe_bolt_dia ),'\n'));
    fprintf(fid,strcat('"Compressed air diameter"=',num2str(compressed_air_dia),'\n'));
    fprintf(fid,strcat('"Ladder bolt diameter"=',num2str(ladder_bolt_dia),'\n'));
    fprintf(fid,strcat('"Lifting Point Length"=',num2str(lifting_point_length),'\n'));
    fclose(fid);
    
    %Fairing File
    fid = fopen(Fairing_file,'w+t');
    fprintf(fid,strcat('"Hull OD"=',num2str(outer_diameter),'\n'));
    fprintf(fid,strcat('"Bottom Frame H"=',num2str(Bottom_Frame_Height ),'\n'));
    fprintf(fid,strcat('"XS height"=',num2str(XS_height ),'\n'));
    fprintf(fid,strcat('"XS width"=',num2str(XS_width ),'\n'));
    fprintf(fid,strcat('"Fairing to Frame Bolt Diameter"=',num2str(fairingtoframe_bolt_dia ),'\n'));
    fprintf(fid,strcat('"Fairing to Fairing Bolt Diameter"=',num2str(fairingtofairing_bolt_dia),'\n'));
    fclose(fid);
    
    %Penetrator,Seating, and Inner Assembly File
    fid = fopen(Penetrator_file,'w+t');
    fprintf(fid,strcat('"Hull OD"=',num2str(outer_diameter),'\n'));
    fprintf(fid,strcat('"Hull ID"=',num2str(inner_diameter),'\n'));
    fprintf(fid,strcat('"Number of Occupants"=',num2str(Occupants),'\n'));
    fprintf(fid,strcat('"Platform Height"=',num2str(platform_height),'\n'));
    fprintf(fid,strcat('"Platform Diameter"=',num2str(platform_diameter),'\n'));
    fprintf(fid,strcat('"second seat"=',num2str(second_seat),'\n'));
    fprintf(fid,strcat('"third seat"=',num2str(third_seat),'\n'));
    fclose(fid);
    
end

%An example of subfunction. 
%Make note that the inputs within the paranthesis have different names than
%the arguments named in the function call. Names themselves do not matter,
%as only the data they contain in passed.

function [density_metal, yield_metal]=get_Metal_properties(Material)
    
    %Eq. (1)
    %Returns density and yield strength based on selection
    
    if Material=="Stainless Steel" %Stainless Steel 316
        yield_metal=290e+06; %Units (Pa)
        density_metal=7750; %Units (kg/m^3)
        
    elseif Material=="Titanium" %Titanium Alloy Ti-5111
        density_metal=4430;
        yield_metal=758e+06;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    else %Aluminium 6061-T6
        density_metal=2700;
        yield_metal=276e+06;
         
    end
end    

function inner_diameter = calc_inner_diameter(Occupants)

    %Eq. (2)
    %Returns diameter value based on number of occupants
    
    if Occupants==1
        inner_diameter=1.3; %Units (m)
        
    elseif Occupants==2
        inner_diameter=1.5;
        
    else
        inner_diameter=1.7;
        
    end    
end        

function outer_diameter = calc_outer_diameter(str, inner_diameter, inner_pressure, outer_pressure)

	%Eq. (3)
    %In this case, we calculate the buckling stress that acts on the hull.
    %This stress predominantly acts circumferentially/longitudinally.
    %Radial stress will be ignore due to their little contribution.
  
    outer_dia=inner_diameter;
    n = 0; %Initial safety factor
   
    %Optimization loop, change diameter until safety factor 'n'>2
    while n<2
        outer_dia = outer_dia + 0.001;
        stress =-(inner_pressure*(inner_diameter/2).^3-outer_pressure*(outer_dia/2).^3+(inner_pressure-outer_pressure)*(((inner_diameter/2)^3)*((outer_dia/2)^3)/(2*((inner_diameter/2)^3))))/(((outer_dia/2)^3)-((inner_diameter/2)^3));   
        n = str/stress;
        
    end
    
    outer_diameter = outer_dia; 
end

function thickness_hatch_door=calc_hatch_door(inner_pressure,outer_pressure,radius_hatch_door,str)
    
    %Eq. (4)
    %In this case, we do a hatch door thickness analysis.
    
    thickness=0; %Assume initial thickness
    n=0; %Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>2
    while n<2
        thickness=thickness+0.001;
        stress=((outer_pressure-inner_pressure)*radius_hatch_door)/(2*thickness);
        n=str/stress;
        
    end
    
    thickness_hatch_door=thickness;
end  

function spring_wire_dia=calc_spring_wire_dia(mass_hatch_door,radius_hatchdoor_to_spring, rod_dia, str,num_spring)
    
    %Eq. (5)
    %In this case, we do a spring hinge analysis.
    
    moment=mass_hatch_door*9.81*radius_hatchdoor_to_spring;
    
    dia=0;
    n=0; %Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>1.5
    while n<1.5
        dia=dia+0.001;
        mean_dia_spring=rod_dia+dia;
        
        c=mean_dia_spring/dia; %spring index
        k=calc_stress_concentration(c); %A call to a subfunction to obtain the spring stress concentration
        
        stress=((k*32*moment)/(pi*dia^3))/num_spring;
        n=str/stress;
        
    end
    
    spring_wire_dia=dia;
    
end

function k=calc_stress_concentration(c)

    %Eq. (6)
    %In this case, we obtain the spring stress concentration from the curve
    %of the spring stress concentration vs spring index, which has been
    %approximated in ranges for simplicity.
    
    if c>=10
        k=1.075;
        
    elseif (9<=c)&&(c<10)
        k=1.08;
        
    elseif (8<=c)&&(c<9)
        k=1.09;
        
    elseif (7<=c)&&(c<8)
        k=1.1;
        
    elseif (6<=c)&&(c<7)
        k=1.125;
        
    elseif (5<=c)&&(c<6)
        k=1.15;
        
    elseif (4<=c)&&(c<5)
        k=1.2;
        
    elseif (3<=c)&&(c<4)
        k=1.275;
        
    else
        k=1.45;
        
    end
end

function [platform_height, platform_diameter,platform_seating_mass,second_seat,third_seat]=calc_platform_dim(Occupants)
    
    %Eq. (7)
    %returns the platform height, platform diameter, seating assembly mass,
    %and returns second_seat==2 if 2 occupants are chosen and second_seat=2
    %and third seat==2 if 3 occupants are chosen. returns 0 for both for 1
    %occupant.
    
    if Occupants==1
        platform_height=0.05; %Units (m)
        platform_diameter=0.7; %Units (m)
        platform_seating_mass=37.57; %Units (kg)
        second_seat=1;
        third_seat=1;
        
    elseif Occupants==2
        platform_height=0.12;
        platform_diameter=1;
        platform_seating_mass=33.04;
        second_seat=2;
        third_seat=1;
        
    else
        platform_height=0.32;
        platform_diameter=1.4;
        platform_seating_mass=28.51;
        second_seat=2;
        third_seat=2;
        
    end
end

function [oxygen_tank_mass,oxygen_tank_submerged_volume] =calc_oxygen_tank_mass(Occupants)

    %Eq. (8)
    %returns the oxygen tank mass and submerged volume given number of
    %occupants.
    
    if Occupants==3
        oxygen_tank_mass=234.14; %Units (kg)
        oxygen_tank_dia=0.13462; %Units (m)
        oxygen_tank_height=0.4191; %Units (m)
        oxygen_tank_submerged_volume=2*(pi/4)*oxygen_tank_dia^2*oxygen_tank_height; %Units (m^3)
        
    elseif Occupants==2
        oxygen_tank_mass=155.4774;
        oxygen_tank_dia=0.10922;
        oxygen_tank_height=0.4191;
        oxygen_tank_submerged_volume=2*(pi/4)*oxygen_tank_dia^2*oxygen_tank_height;
        
    else
        oxygen_tank_mass=92.851;
        oxygen_tank_dia=0.10922;
        oxygen_tank_height=0.2794;
        oxygen_tank_submerged_volume=2*(pi/4)*oxygen_tank_dia^2*oxygen_tank_height;
        
    end
end

function [XS_width, XS_height, Total_Mass,Total_submerged_Mass]=calc_Frame_dimension(x,Total_Mass_without_frame,density_steel,str,Bottom_Frame_Length,Side_Frame_Length,Back_Frame_Length,Top_Frame_Length,Total_Submerged_Mass_without_frame,density_water,depth)
    
    %Eq. (9)
    %returns the frame cross section width and height, the Total Mass, and
    %the Total Submerged Mass
    
    XS_h=0.3;
    XS_w=0.05;
    
    n=2; %Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>1.5
    while n>1.5
        if XS_h>XS_w
            XS_h=XS_h-0.001;
            
        else
            XS_w=XS_w-0.001;
            
        end
        
        [moment, Total_Mass,Total_submerged_Mass]=calc_moment(x,XS_w,XS_h,Total_Mass_without_frame,density_steel,Bottom_Frame_Length,Side_Frame_Length,Back_Frame_Length,Top_Frame_Length,Total_Submerged_Mass_without_frame,density_water,depth); %A call to a subfunction to calculate the moment, Total Mass and Total Submerged Mass
        Inertia=(XS_w*XS_h^3)/12;
        stress=moment*(XS_h/2)/Inertia;
        n=str/stress;
        
    end
    
    XS_height=XS_h;
    XS_width=XS_w;
    
end

function [moment,Total_Mass,Total_submerged_Mass]=calc_moment(x,XS_w,XS_h,Total_Mass_without_frame,density_steel,Bottom_Frame_Length,Side_Frame_Length,Back_Frame_Length,Top_Frame_Length,Total_Submerged_Mass_without_frame,density_water,depth)
    
    %Eq. (10)
    %returns the Moment, Total Mass, and Total Submerged Mass

    Bottom_Frame_Volume=Bottom_Frame_Length*0.22*XS_w;
    Side_Frame_Volume=Side_Frame_Length*XS_h*XS_w;
    Back_Frame_Volume=Back_Frame_Length*XS_h*XS_w;
    Top_Frame_Volume=Top_Frame_Length*XS_h*XS_w;
    Frame_Total_Volume=2*Bottom_Frame_Volume+2*Side_Frame_Volume+Back_Frame_Volume+2*Top_Frame_Volume;
    
    Frame_Total_Mass=Frame_Total_Volume*density_steel;
    Total_Mass_no_ballast_dropweight=Total_Mass_without_frame+Frame_Total_Mass;
    Total_Submerged_Mass_no_ballast_dropweight=Total_Submerged_Mass_without_frame+Frame_Total_Volume*density_water;
    empty_ballast_mass=800*(depth/1000);
    dropweight=Total_Submerged_Mass_no_ballast_dropweight-Total_Mass_no_ballast_dropweight-empty_ballast_mass+200;
    Total_Mass=Total_Mass_no_ballast_dropweight+empty_ballast_mass+dropweight;
    Total_submerged_Mass=Total_Submerged_Mass_no_ballast_dropweight+2200;
    
    moment=(Total_Mass/2)*9.81*x;
    
end

function shear_bolt_dia=calc_shear_bolt_dia(Mass,str,num_bolt, thickness)
    
    %Eq. (11)
    %returns the bolt diameter due to shearing failure
    
    F=Mass*9.81; %Units (N)
    Moment=((F/2)/num_bolt)*thickness/2; %Units (Nm)
    
    dia=0; %Units (m)
    n=0; %Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>2
    while n<2
        dia=dia+0.001;
        stress=(Moment*dia/2)/((pi*dia^4)/64);
        n=str/stress;
        
    end
    
    shear_bolt_dia=dia;
    
end

function fairingtofairing_bolt_dia=tensile_bolt_dia(Mass,str,num_bolt)

    %Eq. (12)
    %returns the bolt diameter due to tensile failure
    
    F=Mass*9.81; %Units (N)
    
    dia=0; %Units (m)
    n=0;%Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>1.5
    while n<1.5
        dia=dia+0.001;
        stress=((F/2)/num_bolt)/((pi/4)*dia^2);
        n=str/stress;
        
    end
    
    fairingtofairing_bolt_dia=dia;
    
end

function lifting_point_length=calc_lifting_point_length(Force_Gravity,XS_width,yield_metal)

    %Eq. (13)
    %In this case, we do a weld failure analysis, in order to obtain
    %weldment length thus obtaining length of lifting point.
    
    Ssy=0.58*yield_metal; %Units (Pa). Yield strength in shear according to
    %distortion energy theory 
    
    height=0.0015; %Units (m). Weld height
    throat=0.707*height; %Units (m). Throat Length
    
    length=0; %Units (m). Length of weld
    n=0;%Initial safety factor
    
    %Optimization loop, change thickness until safety factor 'n'>2
    while n<2
        length=length+0.001;
        Area=throat*length;
        n=Ssy*Area/(Force_Gravity/2);
        
    end
    
    lifting_point_length=(length-(XS_width/2)*2)/2;

end