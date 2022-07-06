cd C:\Users\Zs_Byqx2020\Desktop\CPU_pipeline\src\bin
java -jar Mars4_5.jar dump 0x10010000-0x10010800 HexText data.txt Inst_divided.asm
java -jar Mars4_5.jar dump 0x00400000-0x00400800 HexText inst.txt Inst_divided.asm
python complete.py