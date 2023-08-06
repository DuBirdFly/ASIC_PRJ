import os
from packages.Sim import Sim
from packages.MyFuc import find_files_path

# 环境路径
DIR_PH_CWD = os.getcwd().replace('\\', '/')
DIR_PH_OUT = f"{DIR_PH_CWD}/prj/iverilog"
# 独特名字
NAME = "RoundRobinArbiter"
TB_NAME = f"tb_{NAME}"
# Sim
FILE_PH_VVP = f"{DIR_PH_OUT}/vvp_script.vvp"
DIR_PH_INC = ""
FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/{TB_NAME}.v"
FILES_RTL = find_files_path(f"{DIR_PH_CWD}/user/src", [".v"])

# run sim
sim = Sim(FILE_PH_VVP, DIR_PH_INC, FILE_PH_TBTOP, FILES_RTL)
sim.run_iverilog()
