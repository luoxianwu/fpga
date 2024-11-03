# Lattice Certus-NX dev board start up
## 1. setup FPGA SoC Hardware Platform
download windows propel 2024 IDE and radiant IDE. download free licence for them.   
launch Propel, input the workspace folder. click [launch]    
![image](https://github.com/user-attachments/assets/d0a75cbd-703a-4e5f-afee-2bda3ebe5ef0)   
select Cerate a New Lattice SoC Design Project   
![image](https://github.com/user-attachments/assets/14d8ac61-be6b-4cb1-a328-7c60dce10949)   
select board and template( example ) and [Finish]
![image](https://github.com/user-attachments/assets/68b91eb2-ff4c-49d3-b589-05f32e941184)   

click generate tab , make sure no error. ignore the warnning. 
![image](https://github.com/user-attachments/assets/0683e1f6-62e3-4468-9e97-6dcaf4568fc8) 

run Radiant ![image](https://github.com/user-attachments/assets/bdf8c2c6-ecea-4576-9ab8-b24563e23941)   
In Radiant, run All, It take some time. wait...   
![image](https://github.com/user-attachments/assets/b9359bc0-e8fc-4000-bd67-0e11b6b27106)


# Software Develop 
git clone git@github.com:luoxianwu/fpga.git 
start propel ![image](https://github.com/user-attachments/assets/4059a249-bc2d-4ab9-9c21-951b7e72f89c)
![image](https://github.com/user-attachments/assets/91d9dc63-d3e2-483f-b24c-2bddfaab3b82)   
[launch]
then you can countiue develop software.

# Hardware develop
start propel-builder.   
in builder IDE, File/Open Design,    
select fpga/HW/HW/HW.sbx, then [Open]   
![image](https://github.com/user-attachments/assets/9e81cefd-5e78-4923-8e06-e4b9ca72d240)   
then you can countiue develop hardware.




