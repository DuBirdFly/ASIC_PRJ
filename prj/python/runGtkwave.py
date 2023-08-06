import os
from packages.Sim import Sim

# 环境路径
DIR_PH_CWD = os.getcwd().replace('\\', '/')
DIR_PH_OUT = f"{DIR_PH_CWD}/prj/iverilog"
# 独特名字
NAME = "RoundRobinArbiter"
TB_NAME = f"tb_{NAME}"

Sim.run_gtkwave(f"{DIR_PH_OUT}/{TB_NAME}.vcd")