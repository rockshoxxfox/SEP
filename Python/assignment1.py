import pandas as pd
df = pd.concat(
[pd.read_csv(r'C:\Users\Jack\OneDrive\Antra\python\assignment1\people_1.txt',sep="\t" ,header = 0),
pd.read_csv(r'C:\Users\Jack\OneDrive\Antra\python\assignment1\people_2.txt',sep="\t" ,header = 0)]
)
df['FirstName'] = df['FirstName'].str.lower().str.strip()
df['LastName'] = df['LastName'].str.lower().str.strip()
df['Email'] = df['Email'].str.lower().str.strip()
df['Phone'] = df['Phone'].str.replace('-','').str.strip()
df['Address'] = df['Address'].str.lower().str.replace('no.','').str.replace('#','').str.strip()
df = df.drop_duplicates()
df.to_csv('people.csv')
