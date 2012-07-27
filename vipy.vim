" TODO: add debugger capabilites
" TODO: fine-tune help window
" TODO: figure out what is wrong with ion()
" TODO: better error display
" TODO: finish adding ?
" TODO: make the edit a vim-only command that will open in a new buffer
" TODO: use better syntax highlighting so that error messages and pydoc
" # are colored correctly
" TODO: handle multi-line input_requests (is this ever possible anyways?)
" TODO: test what happens when the vib is in a different window
" TODO: find a way to prevent vib from showing up in buffer list
" TODO: make vim-only commands work even if there are multiple entered
" togethre
" TODO: fix cursor issue
" TODO: better tab complete which can tell if you are in a function call, and return arguments as appropriatey)
" TODO: use the ipython color codes as syntax blocks in vib
" TODO: make sure everything works on mac and linux
" TODO: when there is really long output, and the user is in the vib, then
" make it act like less (so that you can scroll down)
" TODO figure out a way to display the In[nn] and Out[nn] displays (maybe use
" the conceal feature?
" TODO: figure out bug where it won't start properly after booting the
" computer
" TODO: ipython won't close with S-F12 if figures are open; figure out why and
" fix
" TODO: make a movement operator that runs code
" FIXME: running a file with F5 places you in insert mode
" FIXME: the color coding breaks sometimes when if 
" TODO: prevent F9 and other mappings from throwing warnings when python is
" not open
" FIXME: there is a bug that will occur if the vipy buffer isn't shown
" in any window, and you press F12 (I think it only occurs if you have
" changed the vim path using :cd new_directory) The bufexplorer doesn't work
" when this bug occurs
" TODO: handle copy-pasting into vib better
"
" TODO: better documentation
" TODO: user options
" TODO: write the user guide, including advantages of vipy over other
" setups

if !has('python')
    " exit if python is not available.
    finish
endif

" add this back when I am done developing
"if exists("b:did_vimipy")
"   finish
"endif
"let b:did_vimipy = 1

let g:ipy_status="idle"

" TODO finish ascii escape codes
"hi AnsiBlack guibg=NONE guifg=#000000 gui=NONE
"sy region AnsiBlack matchgroup=Hidden start=+\%x1b\[0;30m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiRed guibg=NONE guifg=#ee0000 gui=NONE
"sy region AnsiBlack matchgroup=Hidden start=+\%x1b\[0;31m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiGreen guibg=NONE guifg=#00FF00 gui=NONE
"sy region AnsiGreen matchgroup=Hidden start=+\%x1b\[0;32m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiYellow guibg=NONE guifg=#FFFF00 gui=NONE
"sy region AnsiYellow matchgroup=Hidden start=+\%x1b\[0;33m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiBlue guibg=NONE guifg=#0000FF gui=NONE
"sy region AnsiBlue matchgroup=Hidden start=+\%x1b\[0;34m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiPurple guibg=NONE guifg=#BB00FF gui=NONE
"sy region AnsiPurple matchgroup=Hidden start=+\%x1b\[0;35m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiCyan guibg=NONE guifg=#00FFFF gui=NONE
"sy region AnsiCyan matchgroup=Hidden start=+\%x1b\[0;36m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiLightGray guibg=NONE guifg=#999999 gui=NONE
"sy region AnsiLightGray matchgroup=Hidden start=+\%x1b\[0;37m+ end=+\%x1b\[1m+ concealends contains=ansiConceal
"hi AnsiDarkGray guibg=NONE guifg=#444444 gui=NONE

"sy region AnsiDarkGray matchgroup=Hidden start=+\%x1b\[1;30m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldRed guibg=NONE guifg=#FF0000 gui=NONE
"sy region AnsiBoldRed matchgroup=Hidden start=+\%x1b\[1;31m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldGreen guibg=NONE guifg=#0AFC37 gui=NONE
"sy region AnsiBoldGreen matchgroup=Hidden start=+\%x1b\[1;32m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldYellow guibg=NONE guifg=#FFFF00 gui=NONE
"sy region AnsiBoldYellow matchgroup=Hidden start=+\%x1b\[1;33m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldBlue guibg=NONE guifg=#0000FF gui=NONE
"sy region AnsiBoldBlue matchgroup=Hidden start=+\%x1b\[1;34m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldPurple guibg=NONE guifg=#FF44FF gui=NONE
"sy region AnsiBoldPurple matchgroup=Hidden start=+\%x1b\[1;35m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiBoldCyan guibg=NONE guifg=#00FFFF gui=NONE
"sy region AnsiBoldCyan matchgroup=Hidden start=+\%x1b\[1;36m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"hi AnsiWhite guibg=NONE guifg=#FFFFFF gui=NONE
"sy region AnsiWhite matchgroup=Hidden start=+\%x1b\[1;37m+ end=+\%x1b\[0m+ concealends contains=ansiConceal
"syn match ansiConceal contained conceal "\e\[\(\d*;\)*\d*m"
"sy match ansiSuppress conceal +\%x1b\[0m+


python << EOF
import vim
import sys
import re
from os.path import basename

debugging = False
in_debugger = False
monitor_subchannel = True   # update vipy 'shell' on every send?
run_flags= "-i"             # flags to for IPython's run magic when using <F5>
current_line = ''
vib_ns = 'normalstart'      # used to signify the start of normal highlighting
vib_ne = 'normalend'        # signify the end of normal highlighting

try:
    status
except:
    status = 'idle'
try:
    length_of_last_input_request
except: 
    length_of_last_input_request = 0
try:
    vib
except:
    vib = False
try:
    km
except NameError:
    km = None

# get around unicode problems when interfacing with vim
vim_encoding = vim.eval('&encoding') or 'utf-8'

try:
    sys.stdout.flush
except AttributeError:
    # IPython complains if stderr and stdout don't have flush
    # this is fixed in newer version of Vim
    class WithFlush(object):
        def __init__(self,noflush):
            self.write=noflush.write
            self.writelines=noflush.writelines
        def flush(self):pass
    sys.stdout = WithFlush(sys.stdout)
    sys.stderr = WithFlush(sys.stderr)

## STARTUP and SHUTDOWN
def startup():
    vim.command("augroup vimipython")
    vim.command("au CursorHold * :python update_subchannel_msgs()")
    vim.command("au FocusGained *.py :python update_subchannel_msgs()")
    vim.command("au filetype python setlocal completefunc=CompleteIPython")
    # run shutdown sequense
    vim.command("au VimLeavePre :python shutdown()")
    vim.command("augroup END")

    # TODO: need a good way to ping the server, so that we can see
    # when it is alive, and also tell when it is done booting up
    try:
        msg_id = km.shell_channel.execute('print("I am alive!")')
        content = get_child_msg(msg_id)['content']
    except:
        vim.command('!start /min ipython kernel')
        vim.command('sleep 4')
        km_from_connection_file()

    vib = get_vim_ipython_buffer()
    if vib:
        echo("vipy.py is already open!")
    else:
        # setup the vib buffer if it isn't already open
        setup_vib()
    goto_vib()

    # Update the vipy shell when the cursor is not moving
    # the cursor hold is updated 3 times a second (maximum), but it doesn't
    # update if you stop moving
    vim.command("set updatetime=333") 

def shutdown():
    global km, in_debugger
    in_debugger = False
    try:
        km.shell_channel.shutdown()
    except:
        echo('The kernel must have already shut down.')
    km = None
    
    if is_vim_ipython_open(): # close the window
        goto_vib()
        vim.command('quit')
    # wipe the buffer
    try:
        if vib:
            vim.command('bw ' + vib.name)
    except:
        echo('The vipy buffer must have already been closed.')
    vim.command("au! vimipython")

def km_from_connection_file():
    """ Load kernel using connection file. """
    from IPython.zmq.blockingkernelmanager import BlockingKernelManager, Empty
    from IPython.lib.kernel import find_connection_file
    global km, Empty

    try:
        fullpath = find_connection_file('')
    except IOError:
        vim.command('echoerr("Could not find a IPython connection file, which is necessary to connect to the IPython kernel.")')
    km = BlockingKernelManager(connection_file = fullpath)
    km.load_connection_file()
    km.start_channels()
    return km

def setup_vib():
    """ Setup vib (vipy buffer), that acts like a prompt. """
    global vib, vib_ns, vib_ne
    vim.command("rightbelow vnew vipy.py")
    # set the global variable for everyone to reference easily
    vib = get_vim_ipython_buffer()
    new_prompt(append=False)

    vim.command("setlocal nonumber")
    vim.command("setlocal bufhidden=hide buftype=nofile ft=python noswf nobl")
    # turn of auto indent (there is some custom indenting that accounts
    # for the prompt).  See vim-tip 330
    vim.command("setl noai nocin nosi inde=") 
    vim.command("syn match Normal /^>>>/")

    # mappings to control sending stuff from vipy
    vim.command("inoremap <buffer> <silent> <s-cr> <ESC>:py shift_enter_at_prompt()<CR>")
    vim.command("nnoremap <buffer> <silent> <s-cr> <ESC>:py shift_enter_at_prompt()<CR>")
    vim.command("inoremap <buffer> <silent> <cr> <ESC>:py enter_at_prompt()<CR>")

    # setup history mappings etc.
    enter_normal(first=True)

    # commands for escaping
    vim.command("noremap <buffer> <silent> <F12> <ESC><C-w>p")
    vim.command("inoremap <buffer> <silent> <F12> <ESC><C-w>p")
    # add and auto command, so that the cursor always moves to the end
    # upon entereing the vipy buffer
    vim.command("au WinEnter <buffer> :python insert_at_new()")
    # not working; the idea was to make
    # vim.command("au InsertEnter <buffer> :py if above_prompt(): vim.command('normal G$')")
    vim.command("setlocal statusline=\ \ \ %-{g:ipy_status}")
    
    # handle syntax coloring a little better
    if vim.eval("has('conceal')"): # if vim has the conceal option
        vim.command("syn region Normal matchgroup=Hidden start=/^" + vib_ns + "/ end=/" + vib_ne + "$/ concealends")
        vim.command("setlocal conceallevel=3")
        vim.command('setlocal concealcursor=nvic')
    else: # otherwise, turn of the ns, ne markers
        vib_ns = ''
        vib_ne = ''

def enter_normal(first=False):
    global vib_map, in_debugger
    in_debugger = False
    vib_map = "on"
    in_debugger = False
    # mappings to control history
    vim.command("inoremap <buffer> <silent> <up> <ESC>:py prompt_history('up')<CR>")
    vim.command("inoremap <buffer> <silent> <down> <ESC>:py prompt_history('down')<CR>")

    # make some normal vim commands convenient when in the vib
    vim.command("nnoremap <buffer> <silent> dd cc>>> ")
    vim.command("noremap <buffer> <silent> <home> 0llll")
    vim.command("inoremap <buffer> <silent> <home> <ESC>0llla")
    vim.command("noremap <buffer> <silent> 0 0llll")

    # unmap debug codes
    if not first:
        try:
            vim.command("nunmap <F10>")
            vim.command("nunmap <F11>")
            vim.command("nunmap <C-F11>")
            vim.command("nunmap <S-F5>")
        except vim.error:
            pass

def enter_debug():
    """ Remove all the convenience mappings. """
    global vib_map, in_debugger
    vib_map = "off"
    in_debugger = True
    try:
        vim.command("iunmap <buffer> <silent> <up>")
        vim.command("iunmap <buffer> <silent> <down>")
        vim.command("iunmap <buffer> <silent> <right>")
        vim.command("nunmap <buffer> <silent> dd")
        vim.command("nunmap <buffer> <silent> <home>")
        vim.command("iunmap <buffer> <silent> <home>")
        vim.command("nunmap <buffer> <silent> 0")
    except vim.error:
        pass

    vim.command("nnoremap <F10> :py db_step()<CR>")
    vim.command("nnoremap <F11> :py db_stepinto()<CR>")
    vim.command("nnoremap <C-F11> :py db_stepout()<CR>")
    vim.command("nnoremap <F5> :py db_continue()<CR>") # this is set below
    vim.command("nnoremap <S-F5> :py db_quit()<CR>")

## DEBUGGING
""" I think the best way to do visual debugging will be to use marks for break
points.  Originally I wanted to use signs, but it doesn't seem like there is
any way to access there locations when you are in python.  Marks you can
access, and set.  You can access them directly, you can set them using the
setpos() vim function.  I think marks in combination with the showmarks
plugin, will allow us to make a really good visual debugger that is laid on
top of pdb. """
# TODO: figure out a way to know when you are out of the debugger

vim.command("sign define pypc texthl=ProgCount text=>>")
vim.command("hi ProgCount guibg=#000000 guifg=#00FE33 gui=bold")

bps = []

def update_pg():
    """ Place a sign in the file specified by the last raw_input request with pdb"""
    for i in range(len(vib)):
        pass


def signs_to_bps():
    pass

def db_check(fun):
    """ Check whether in debug mode and print prompt. """
    def wrapper():
        global in_debugger
        if in_debugger:
            prompt = fun()
        else:
            return

    return wrapper

@db_check
def db_step():
    km.stdin_channel.input('n')
    return 'next'

@db_check
def db_stepinto():
    km.stdin_channel.input('s')
    return 'step'

@db_check
def db_stepout():
    km.stdin_channel.input('unt')
    return 'until'

def db_continue():
    global in_debugger, bps
    if not in_debugger:
        if len(bps) == 0:
            run_this_file()
            return
        msg_id = send("get_ipython().magic(u'run -d %s')" % (repr(vim.current.buffer.name)[1:-1]))
        in_debugger = True
    km.stdin_channel.input('c')
    return 'continue'

@db_check
def db_quit():
    km.stdin_channel.input('q')
    in_debugger = False
    return 'quit'

## COMMAND-LINE-HISTORY
need_new_hist = True
last_hist = []
hist_pos = 0
num_lines_added_last = 1
hist_prompt = '>>> '
hist_last_appended = ''
def prompt_history(key):
    """ Poll server for history if a new search is needed, otherwise rotate
    through matches. """

    global last_hist, hist_pos, need_new_hist, num_lines_added_last, hist_prompt, hist_last_appended
    if not at_end_of_prompt():
        r,c = vim.current.window.cursor
        if key == "up":
            if not r == 1:
                vim.current.window.cursor = (r - 1, c)
        elif key == "down":
            if not r == len(vim.current.buffer):
                vim.current.window.cursor = (r + 1, c)
        return
    if status == "busy":
        # echo("No history available because the python server is busy.")
        # the message gets overridden immedieatly when the mapping switches back to 
        # insert mode
        return
    if not vib[-1] == hist_last_appended:
        need_new_hist = True
    if need_new_hist:
        cl = vim.current.line
        if len(cl) > 4: # search for everything starting with the current line
            pat = cl[4:] + '*'
            msg_id = km.shell_channel.history(hist_access_type='search', pattern=pat)
        else: # return the last 100 inputs
            pat = ' '
            msg_id = km.shell_channel.history(hist_access_type='tail', n=50)
        hist_prompt = cl[:4] if len(cl) >= 4 else '>>> '
            
        hist = get_child_msg(msg_id)['content']['history']
        # sort the history by time
        last_hist = sorted(hist, key=hist_sort, reverse=True)
        last_hist = [hi[2].encode(vim_encoding) for hi in last_hist] + [pat[:-1]]
        need_new_hist = False
        hist_pos = 0
        num_lines_added_last = 1
    else:
        if key == "up":
            hist_pos = (hist_pos + 1) % len(last_hist)
        else: # if key == "down"
            hist_pos = (hist_pos - 1) % len(last_hist)

    # remove the previously added lines
    if num_lines_added_last > 1:
        del vib[-(num_lines_added_last - 1):]
    toadd = format_for_prompt(last_hist[hist_pos], firstline=hist_prompt)
    num_lines_added_last = len(toadd)

    vib[-1] = toadd[0]
    for line in toadd[1:]:
        vib.append(line)
    hist_last_appended = toadd[-1]

    vim.command('normal G$')
    vim.command('startinsert!')

def hist_sort(hist_item):
    """ Sort history items such that the most recent sessions has highest
    priority.
    
    hist_item is a tuple with: (session, line_number, input)
    where session and line_number increase through time. """
    return hist_item[0]*10000 + hist_item[1]

## COMMAND LINE 
numspace = re.compile(r'^[>.]{3}(\s*)')
def enter_at_prompt():
    if at_end_of_prompt():
        match = numspace.match(vib[-1])
        if match:
            space_on_lastline = match.group(1)
        else:
            space_on_lastline = ''
        vib.append('...' + space_on_lastline)
        vim.command('normal G')
        vim.command('startinsert!')
    else:
        # do a normal return FIXME
        # vim.command('call feedkeys("\<CR>")')
        vim.command('normal <CR>')

def shift_enter_at_prompt():
    """ Remove prompts and whitespace before sending to ipython. """
    if status == 'input requested':
        km.stdin_channel.input(vib[-1][length_of_last_input_request:])
    else:
        stop_str = r'>>>'
        cmds = []
        linen = len(vib)
        while linen > 0:
            # remove the last three characters
            cmds.append(vib[linen - 1][4:]) 
            if vib[linen - 1].startswith(stop_str):
                break
            else:
                linen -= 1
        cmds.reverse()

        cmds = '\n'.join(cmds)
        if cmds == 'cls' or cmds == 'clear':
            vib[:] = None # clear the buffer
            new_prompt(append=False)
            return
            # TODO: allow the user to start editing a file from command window
            #        elif cmds.startswith('edit '):
            #            fnames = cmds[5:].split(' ')
            #            msg_id = km.shell_channel.execute('%pwd')
            #            try:
            #                pwd = get_child_msg(msg_id)['content']
            #                vib.append(repr(pwd).splitlines())
            #                pwd = pwd['data']['text/plain']
            #            except Empty:
            #                # timeout occurred
            #                return echo("no reply from IPython kernel")
            #            for fname in fnames:
            #                vib.append(pwd + fname)
        elif cmds.endswith('??'):
            msg_id = km.shell_channel.object_info(cmds[:-2])
            try:
                content = get_child_msg(msg_id)['content']
            except Empty:
                # timeout occurred
                return echo("no reply from IPython kernel")
            if content['found']:
                vim.command("drop " + content['file'])
            else:
                echo("No object informat was found.  Make sure that the requested object has been executed and is in the interactive namespace, otherwise IPython won't be aware of it.")
            new_prompt()
        elif cmds.endswith('?'):
            content = use_normal_highlighting(get_doc(cmds[:-1]))
            if content == '':
                content =  'No matches found for: %s' % cmds[:-1]
            vib.append(content)
            new_prompt()
            return
        else:
            send(cmds)
            # make vim poll for a while
            ping_count = 0
            while ping_count < 30 and not update_subchannel_msgs():
                vim.command("sleep 20m")
                ping_count += 1

def new_prompt(goto=True, append=True):
    if append:
        vib.append('>>> ')
    else:
        vib[-1] = '>>> '
    if goto:
        vim.command('normal G')
        vim.command('startinsert!')

def format_for_prompt(cmds, firstline='>>> ', limit=False):
    # format and input text
    max_lines = 10
    lines_to_show_when_over = 4
    if debugging:
        vib.append('this is what is being formated for the prompt:')
        vib.append(cmds)
    if not cmds == '':
        formatted = re.sub(r'\n',r'\n... ',cmds).splitlines()
        lines = len(formatted)
        if limit and lines > max_lines:
            formatted = formatted[:lines_to_show_when_over] + ['... (%d more lines)' % (lines - lines_to_show_when_over)]
        formatted[0] = firstline + formatted[0]
        return formatted
    else:
        return [firstline]

## IPYTHON-VIM COMMUNICATION
blankprompt = re.compile(r'^\>\>\> $')
def send(cmds, *args, **kargs):
    """ Send commands to ipython kernel. 

    Format the input, then print the statements to the vipy buffer.
    """
    formatted = None
    if status == 'input requested':
        echo('Can not send further commands until you respond to the input request.')
        return 
    elif status == 'busy':
        echo('Can not send commands while the python kernel is busy.')
        return
    if not in_vim_ipython():
        formatted = format_for_prompt(cmds, limit=True)

        # remove any prompts or blank lines
        while len(vib) > 1 and blankprompt.match(vib[-1]):
            del vib[-1]
            
        if blankprompt.match(vib[-1]):
            vib[-1] = formatted[0]
        else:
            vib.append(formatted) 
    val = km.shell_channel.execute(cmds, *args, **kargs)
    return val


def update_subchannel_msgs(debug=False):
    """ This function grabs messages from ipython and acts accordinly; note
    that communications are asynchronous, and furthermore there is no good way to
    repeatedly trigger a function in vim.  There is an autofunction that will
    trigger whenever the cursor moves, which is the next best thing.
    """
    global status, length_of_last_input_request
    if km is None:
        return False
    newprompt = False
    gotoend = False # this is a hack for moving to the end of the prompt when new input is requested that should get cleaned up

    msgs = km.sub_channel.get_msgs()
    msgs += km.stdin_channel.get_msgs() # also handle messages from stdin
    for m in msgs:
        if debugging:
            vib.append('message from ipython:')
            vib.append(repr(m).splitlines())
        if 'msg_type' not in m['header']:
            continue
        else:
            msg_type = m['header']['msg_type']
            
        s = None
        if msg_type == 'status':
            if m['content']['execution_state'] == 'idle':
                status = 'idle'
                newprompt = True
            else:
                newprompt = False
            if m['content']['execution_state'] == 'busy':
                status = 'busy'
            vim.command('let g:ipy_status="' + status + '"')
        elif msg_type == 'stream':
            s = strip_color_escapes(m['content']['data'])
            s = use_normal_highlighting(s)
        elif msg_type == 'pyout':
            s = m['content']['data']['text/plain']
        elif msg_type == 'pyin':
            # don't want to print the input twice
            continue
        elif msg_type == 'pyerr':
            c = m['content']
            s = "\n".join(map(strip_color_escapes,c['traceback']))
            s = "\n".join(map(strip_color_escapes,c['traceback']))
            # s += c['ename'] + ": " + c['evalue']
        elif msg_type == 'object_info_reply':
            c = m['content']
            if not c['found']:
                s = c['name'] + " not found!"
            else:
            # TODO: finish implementing this
                s = use_normal_highlighting(c['docstring'])
        elif msg_type == 'input_request':
            s = m['content']['prompt']
            status = 'input requested'
            vim.command('let g:ipy_status="' + status + '"')
            length_of_last_input_request = len(m['content']['prompt'])
            gotoend = True

        elif msg_type == 'crash':
            s = "The IPython Kernel Crashed!"
            s += "\nUnfortuneatly this means that all variables in the interactive namespace were lost."
            s += "\nHere is the crash info from IPython:\n"
            s += repr(m['content']['info'])
            s += "Type CTRL-F12 to restart the Kernel"
        
        if s: # then update the vipy buffer with the formatted text
            if s.find('\n') == -1: # then use ugly unicode workaround from 
                # http://vim.1045645.n5.nabble.com/Limitations-of-vim-python-interface-with-respect-to-character-encodings-td1223881.html
                if isinstance(s,unicode):
                    s = s.encode(vim_encoding)
                vib.append(s)
                if debugging:
                    vib.append('using unicode workaround')
            else:
                try:
                    vib.append(s.splitlines())
                except:
                    vib.append([l.encode(vim_encoding) for l in s.splitlines()])
        
    # move to the vipy (so that the autocommand can scroll down)
    if in_vim_ipython():
        if newprompt:
            new_prompt()
        if gotoend:
            goto_vib()

        # turn off some mappings when input is requested (e.g. the history search)
        if status == "input requested" and vib_map == "on":
            enter_debug()
        if vib_map == "off" and status != "input requested":
            enter_normal()

    else:
        if newprompt:
            new_prompt(goto=False)
        if is_vim_ipython_open():
            goto_vib(insert_at_end=False)
            vim.command('exe "normal G\<C-w>p"')
    return len(msgs)

            
def get_child_msg(msg_id):
    # XXX: message handling should be split into its own process in the future
    while True:
        # get_msg will raise with Empty exception if no messages arrive in 5 second
        m= km.shell_channel.get_msg(timeout=5)
        if m['parent_header']['msg_id'] == msg_id:
            break
        else:
            #got a message, but not the one we were looking for
            if debugging:
                echo('skipping a message on shell_channel','WarningMsg')
    return m
            
def with_subchannel(f,*args):
    "conditionally monitor subchannel"
    def f_with_update(*args):
        try:
            f(*args)
            if monitor_subchannel:
                update_subchannel_msgs()
        except AttributeError: #if km is None
            echo("not connected to IPython", 'Error')
    return f_with_update

@with_subchannel
def run_this_file():
    msg_id = send("get_ipython().magic(u'run %s %s')" % (run_flags, repr(vim.current.buffer.name)[1:-1]))

@with_subchannel
def run_this_line():
    # don't send blank lines
    if vim.current.line != '':
        msg_id = send(vim.current.line.strip())

ws = re.compile(r'\s*')
@with_subchannel
def run_these_lines():
    vim.command('normal y')
    lines = vim.eval("getreg('0')").splitlines()
    ws_length = len(ws.match(lines[0]).group())
    lines = [line[ws_length:] for line in lines]
    msg_id = send("\n".join(lines))

## HELP BUFFER
try:
    vihb
except:
    vihb = None

def get_doc(word):
    msg_id = km.shell_channel.object_info(word)
    doc = get_doc_msg(msg_id)
    if len(doc) == 0:
        return ''
    else:
        # get around unicode problems when interfacing with vim
        return [d.encode(vim_encoding) for d in doc]

def get_doc_msg(msg_id):
    n = 13 # longest field name (empirically)
    b=[]
    try:
        content = get_child_msg(msg_id)['content']
    except Empty:
        # timeout occurred
        return ["no reply from IPython kernel"]

    if not content['found']:
        return b

    for field in ['type_name','base_class','string_form','namespace',
            'file','length','definition','source','docstring']:
        c = content.get(field,None)
        if c:
            if field in ['definition']:
                c = strip_color_escapes(c).rstrip()
            s = field.replace('_',' ').title() + ':'
            s = s.ljust(n)
            if c.find('\n')==-1:
                b.append(s+c)
            else:
                b.append(s)
                b.extend(c.splitlines())
    return b

def get_doc_buffer(level=0):
    global vihb
    if status == 'busy':
        echo("Can't query for Help When IPython is busy.  Do you have figures opened?")
    if km is None:
        echo("Not connected to the IPython kernel... Type CTRL-F12 to start it.")

    # empty string in case vim.eval return None
    word = vim.eval('expand("<cfile>")') or ''
    doc = get_doc(word)
    if len(doc) == 0 :
        echo(repr(word) + " not found", "Error")
        # TODO: revert to normal K
        return

    # see if the doc window has already been made, if not create it
    try:
        vihb
    except:
        vihb = None
    if not vihb:
        vim.command('new vipy-help.py')
        vihb = vim.current.buffer
        vim.command('setlocal modifiable noro nonumber')
        vim.command("noremap <buffer> K <C-w>p")
        # doc window quick quit keys: 'q' and 'escape'
        vim.command('noremap <buffer> q :q<CR>')
        # Known issue: to enable the use of arrow keys inside the terminal when
        # viewing the documentation, comment out the next line
        vim.command('map <buffer> <Esc> :q<CR>')
        vim.command('setlocal nobl')
        vim.command('resize 20')

    # fill the window with the correct content
    vihb[:] = None
    vihb[:] = doc

## HELPER FUNCTIONS
def goto_vib(insert_at_end=True):
    global vib
    try:
        name = vib.name
        vim.command('drop ' + name)
        if insert_at_end:
            vim.command('normal G')
            vim.command('startinsert!')
    except vim.error:
        echo("It appears that the vipy.py buffer was deleted.  You can create a new one without reseting the python server (and losing any variables in the interactive namespace) by running the command :python setup_vib(), or you can reset the server by pressing SHIFT-F12 to shutdown the server, and then CTRL-F12 to start it up again along with a new vipy buffer.")
        vib = None


def at_end_of_prompt():
    """ Is the cursor at the end of a prompt line? """
    row, col = vim.current.window.cursor
    lineend = len(vim.current.line) - 1
    bufend = len(vim.current.buffer)
    return numspace.match(vim.current.line) and row == bufend and col == lineend

def above_prompt():
    """ See if the cursor is above the last >>> prompt. """
    row, col = vim.current.window.cursor
    i = len(vib) - 1
    last_prompt = 0
    while i >= 0:
        if vib[i].startswith(r'>>> '):
            last_prompt = i + 1 # convert from index to line-number
            break
    if row < last_prompt:
        return True
    else:
        return False

def use_normal_highlighting(s):
    """ Surround the text with syntax hints so that it uses the normal 
    highlighting.  This is accomplished using the vib_ns and vib_ne (normal
    start/end) strings. """ 
    if isinstance(s, list):
        if len(s) > 0:
            s[0] = vib_ns + s[0]
            s[-1] = s[-1] + vib_ne
    else: # if it is string
        if s == '':
            return ''
        if s[-1] == '\n':
            s = vib_ns + s[:-1] + vib_ne + '\n'
        else:
            s = vib_ns + s + vib_ne
    return s

def is_vim_ipython_open():
    """
    Helper function to let us know if the vipy shell is currently
    visible
    """
    for w in vim.windows:
        if w.buffer.name is not None and w.buffer.name.endswith("vipy.py"):
            return True
    return False

def in_vim_ipython():
    cbn = vim.current.buffer.name
    if cbn:
        return cbn.endswith('vipy.py')
    else:
        return False

def insert_at_new():
    """ Insert at the bottom of the file, if it is the ipy buffer. """
    if in_vim_ipython():
        # insert at end of last line
        vim.command('normal G')
        vim.command('startinsert!') 

def get_vim_ipython_buffer():
    """ Return the vipy buffer. """
    for b in vim.buffers:
        try:
            if b.name.endswith("vipy.py"):
                return b
        except:
            continue
    return False

def get_vim_ipython_window():
    """ Return the vipy window. """
    for w in vim.windows:
        if w.buffer.name is not None and w.buffer.name.endswith("vipy.py"):
            return w
    raise Exception("couldn't find vipy window")

def echo(arg,style="Question"):
    try:
        vim.command("echohl %s" % style)
        vim.command("echom \"%s\"" % arg.replace('\"','\\\"'))
        vim.command("echohl None")
    except vim.error:
        print "-- %s" % arg

# from http://serverfault.com/questions/71285/in-centos-4-4-how-can-i-strip-escape-sequences-from-a-text-file
strip = re.compile('\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]')
def strip_color_escapes(s):
    return strip.sub('',s)

EOF

" MAPPINGS
nnoremap <silent> <C-F5> :wa<CR>:py run_this_file()<CR><ESC>
inoremap <silent> <C-F5> <ESC>:wa<CR>:py run_this_file()<CR>
noremap <silent> K :py get_doc_buffer()<CR>
vnoremap <silent> <F9> y:py run_these_lines()<CR><ESC>
nnoremap <silent> <F9> :py run_this_line()<CR><ESC>j
noremap <silent> <F12> :py goto_vib()<CR>
noremap <silent> <C-F12> :py startup()<CR>
noremap <silent> <S-F12> :py shutdown()<CR>
inoremap <silent> <F12> <ESC>:py goto_vib()<CR>
inoremap <silent> <C-F12> <ESC>:py startup()<CR>
inoremap <silent> <S-F12> <ESC>:py shutdown()<CR>
inoremap <silent> <S-CR> <ESC>:set nohlsearch<CR>V?^\n<CR>:python run_these_lines()<CR>:let @/ = ""<CR>:set hlsearch<CR>Go<ESC>o

" TODO: add back cell evaluation mappings (similar to matlab)
"nnoremap <silent> <S-CR> :set nohlsearch<CR>/^\n<CR>V?^\n<CR>:python run_these_lines()<CR>:let @/ = ""<CR>:set hlsearch<CR>j
"nnoremap <silent> <C-CR> :set nohlsearch<CR>/^##\\|\%$<CR>:let @/ = ""<CR>kV?^##\\|\%^<CR>:python run_these_lines()<CR>:let @/ = ""<CR>:set hlsearch<CR>
"" same as above, except moves to the next cell
"nnoremap <silent> <C-S-CR> :set nohlsearch<CR>/^##\\|\%$<CR>:let @/ = ""<CR>kV?^##\\|\%^<CR>:python run_these_lines()<CR>N:let @/ = ""<CR>:set hlsearch<CR>

fun! CompleteIPython(findstart, base)
      if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start-1] =~ '\k\|\.' "keyword
          let start -= 1
        endwhile
        echo start
        python << endpython
current_line = vim.current.line
endpython
        return start
      else
        " find months matching with "a:base"
        let res = []
        python << endpython
base = vim.eval("a:base")
findstart = vim.eval("a:findstart")
msg_id = km.shell_channel.complete(base, current_line, vim.eval("col('.')"))
try:
    m = get_child_msg(msg_id)
    matches = m['content']['matches']
    matches.insert(0,base) # the "no completion" version
    # we need to be careful with unicode, because we can have unicode
    # completions for filenames (for the %run magic, for example). So the next
    # line will fail on those:
    #completions= [str(u) for u in matches]
    # because str() won't work for non-ascii characters
    # and we also have problems with unicode in vim, hence the following:
    completions = [s.encode(vim_encoding) for s in matches]
except Empty:
    echo("no reply from IPython kernel")
    completions=['']
## Additionally, we have no good way of communicating lists to vim, so we have
## to turn in into one long string, which can be problematic if e.g. the
## completions contain quotes. The next line will not work if some filenames
## contain quotes - but if that's the case, the user's just asking for
## it, right?
#completions = '["'+ '", "'.join(completions)+'"]'
#vim.command("let completions = %s" % completions)
## An alternative for the above, which will insert matches one at a time, so
## if there's a problem with turning a match into a string, it'll just not
## include the problematic match, instead of not including anything. There's a
## bit more indirection here, but I think it's worth it
for c in completions:
    vim.command('call add(res,"'+c+'")')
endpython
        "call extend(res,completions) 
        return res
      endif
    endfun

