import pandas as pd

data = pd.read_table('testprocessor_Data_Export.tsv', low_memory = 'False')

data.RecordingName

subjectNames = set(data.RecordingName)

while len(subjectNames) > 0:
    subjectName = subjectNames.pop()
    subjectFile = data[data.RecordingName == subjectName]
    
    fileName = subjectName + '.xlsx'
    subjectFile.to_excel(fileName)