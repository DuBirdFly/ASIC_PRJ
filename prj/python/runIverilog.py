import os
from packages.Sim import Sim

# 环境路径
DIR_PH_CWD = os.getcwd().replace('\\', '/')
DIR_PH_OUT = f"{DIR_PH_CWD}/prj/iverilog"
# 独特名字
NAME = "SyncFIFO_Bypass"
TB_NAME = f"tb_{NAME}"
# Sim
FILE_PH_VVP = f"{DIR_PH_OUT}/vvp_script.vvp"
DIR_PH_INC = ""
FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/{TB_NAME}.v"
FILES_RTL = [f"{DIR_PH_CWD}/user/src/{NAME}.v"]
FILES_RTL.append(f"{DIR_PH_CWD}/user/src/SyncFIFO.v")

# run sim
sim = Sim(FILE_PH_VVP, DIR_PH_INC, FILE_PH_TBTOP, FILES_RTL)
sim.run_iverilog()
