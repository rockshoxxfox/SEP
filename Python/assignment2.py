import pandas as pd
import numpy as np
df = pd.read_json(r'C:\Users\Jack\OneDrive\Antra\python\assignment1\movie.json')
ndf = np.array_split(df,8)
n = 1
for i in ndf:
    i.to_json(f'{n}.json')
    n+=1
