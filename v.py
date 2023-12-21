from tkinter import *
from tkinter.filedialog import asksaveasfilename, askopenfilename
import subprocess

compiler = Tk()
compiler.title("SUDO IDE")
file_path = ''

def set_file_path(path):
    global file_path
    file_path = path

def open_file():
    path = askopenfilename(filetypes=[('Fichiers SPL', '*.spl')])
    with open(path, 'r') as file:
        code = file.read()
        editor.delete('1.0', END)
        editor.insert('1.0', code)
        set_file_path(path)

def save_as():
    if file_path == '':
        path = asksaveasfilename(filetypes=[('Fichiers SPL', '*.spl')])
    else:
        path = file_path
    with open(path, 'w') as file:
        code = editor.get('1.0', END)
        file.write(code)
        set_file_path(path)

def run():
    if file_path == '':
        save_prompt = Toplevel()
        text = Label(save_prompt, text='Veuillez enregistrer votre code')
        text.pack()
        return
    command = 'flex -o sudo_lex.c sudo_lex.lex; bison -d sudo_syntaxe.y; gcc sudo_lex.c sudo_syntaxe.tab.c sudo_code_generator.c `pkg-config --cflags --libs glib-2.0` -o spl; ./spl text.spl; gcc -o h text.c; ./h'
    
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    code_output.insert('1.0', output)
    code_output.insert('1.0',  error)

menu_bar = Menu(compiler)

file_menu = Menu(menu_bar, tearoff=0)
file_menu.add_command(label='Ouvrir', command=open_file)
file_menu.add_command(label='Enregistrer', command=save_as)
file_menu.add_command(label='Enregistrer sous', command=save_as)
file_menu.add_command(label='Quitter', command=exit)
menu_bar.add_cascade(label='Fichier', menu=file_menu)

run_bar = Menu(menu_bar, tearoff=0)
run_bar.add_command(label='Exécuter', command=run)
menu_bar.add_cascade(label='Exécuter', menu=run_bar)

compiler.config(menu=menu_bar)

editor = Text(height=35,width=220)
editor.pack()




code_output = Text(height=20,width=220)
code_output.pack()







# Obtenir la taille de l'écran
largeur_ecran = compiler.winfo_screenwidth()
hauteur_ecran = compiler.winfo_screenheight()

# Définir la taille maximale de la fenêtre principale
compiler.wm_maxsize(largeur_ecran, hauteur_ecran)

# Définir la taille de la fenêtre principale
compiler.geometry(f"{int(largeur_ecran*0.9)}x{int(hauteur_ecran*0.9)}+{int(largeur_ecran*0.1)}+{int(hauteur_ecran*0.1)}")

compiler.mainloop()