from tkinter import *
from tkinter.ttk import Progressbar
import os

root = Tk()

image = PhotoImage(file='hpp.png')
largeur_ecran = root.winfo_screenwidth()
hauteur_ecran = root.winfo_screenheight()
root.geometry(f"{int(largeur_ecran*0.4)}x{int(hauteur_ecran*0.4)}+{int(largeur_ecran*0.3)}+{int(hauteur_ecran*0.2)}")
root.overrideredirect(1)

root.wm_attributes('-topmost', True)
root.lift()
root.wm_attributes("-topmost", True)

bg_label = Label(root, image=image, bg='white')
bg_label.place(x=0, y=0)

progress_label = Label(root,text="Loading",font=('Comic Sans MS',19,'bold'),fg='blue',bg='white')
progress_label.place(x=490, y=365)
progresse= Progressbar(root,orient=HORIZONTAL,length=360,mode='determinate')
progresse.place(x=399, y=411)

def top():
    root.withdraw()
    os.system("python3 v.py")
    root.destroy()

i=0
def load():
    global i
    if i <= 10:
        txt ='Loading..........'+(str(10*i)+'%')
        progress_label.config(text=txt)
        progress_label.after(1000,load)
        progresse['value']=10*i
        i+=1

    else:
        top()
load()

root.mainloop()
