import subprocess, sys, os
from MyFuc import run_cmd

class Sim:

    def __init__(
        self,
        # 路径均为绝对路径, 注意 filepath 与 dirpath 的区别
        filepath_vvp_script : str,
        dirpath_defines : str,
        filepath_tb_top : str,
        # dirpath_rtls : str
        rtl_filepaths : list
    ):

        self.ivg_cmd = ["iverilog"]
        self.vvp_cmd = ["vvp", filepath_vvp_script]

        dirpath_vvp_script = os.path.dirname(filepath_vvp_script)
        if os.path.exists(os.path.dirname(dirpath_vvp_script)):
            self.ivg_cmd.extend(["-o", filepath_vvp_script])         # '-o' --> output
        else:
            raise Exception(f"ERROR: {filepath_vvp_script}所处的文件夹不存在")

        if os.path.exists(dirpath_defines):
            self.ivg_cmd.extend(["-I", dirpath_defines])                # '-I' --> includedir
        elif dirpath_defines != "":
                raise Exception(f"ERROR: {dirpath_defines}文件夹不存在") 

        if os.path.exists(filepath_tb_top):
            self.ivg_cmd.append(filepath_tb_top)
        else:
            raise Exception(f"ERROR: {filepath_tb_top}文件不存在")              

        # 指定其他的rtl文件
        # filepaths = []
        # for root, dirnames, filenames in os.walk(dirpath_rtls):
        #     for filename in filenames:
        #         if filename.endswith(".v") or filename.endswith(".sv"):
        #             filepaths.append(os.path.join(root, filename))

        if rtl_filepaths: self.ivg_cmd.extend(rtl_filepaths)

    def run_iverilog(self):
        sys.stdout.write("----------------------------------\n")
        sys.stdout.write("-------- PROCESS : Sim.py --------\n")
        sys.stdout.write("----------------------------------\n")

        sys.stdout.write(' '.join(self.ivg_cmd) + "\n")

        run_cmd(self.ivg_cmd)
        run_cmd(self.vvp_cmd)

    @staticmethod
    def run_gtkwave(filepath_vcd):
        sys.stdout.write("------------ GtkWave -------------\n")

        if not os.path.exists(filepath_vcd):
            raise Exception(f"ERROR: {filepath_vcd}文件不存在")

        subprocess.run(["gtkwave", filepath_vcd])
        

if __name__ == "__main__":

    if len(sys.argv) == 5:  # sys.argv[0] 是本文件的路径
        Sim(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]).run()
    else:
        # raise Exception("Sim.py: 参数数量错误\n")
        DIR_PH_CWD = os.getcwd().replace('\\', '/')
        DIR_PH_OUT = f"{DIR_PH_CWD}/prj/iverilog"
        # Sim
        FILE_PH_VVP = f"{DIR_PH_OUT}/vvp_script.vvp"
        DIR_PH_INC = ""
        FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/tb_SyncFIFO.v"
        # DIR_PH_RTL = f"{DIR_PH_CWD}/user/src"
        RTL_FILEPATHS = [f"{DIR_PH_CWD}/user/src/SyncFIFO.v"]
        sim = Sim(FILE_PH_VVP, DIR_PH_INC, FILE_PH_TBTOP, RTL_FILEPATHS)
        sim.run_iverilog()
        # sim.run_gtkwave(f"{DIR_PH_OUT}/tb_SyncFIFO.vcd")