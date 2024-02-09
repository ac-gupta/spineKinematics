import pymeshlab as ml
import os

ms = ml.MeshSet()

dir = os.getcwd()

for file in os.listdir(dir):
    f = os.fsdecode(file)

    if f.endswith(".stl"):

        fNew = f[:-4] + "_dec.stl"

        # apply filter
        ms.load_new_mesh(f)
        ms.load_filter_script('Decimation.mlx')
        ms.apply_filter_script()
        ms.save_current_mesh(fNew)

