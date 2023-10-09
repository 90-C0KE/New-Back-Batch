""" Old Code:
from rich.console import Console as richConsole
import os
import socket
import threading

## Set up console
Console = richConsole()

## Socket Details
_host = "127.0.0.1"
_port = 55035

## Start
os.system("title BackBatch")
os.system("cls")
Console.print("\n[ENTER DEVICE]", style="red")
"""

########################
## Back Batch Master ###
## By 1k0de          ###
########################
## Textualize Docs: https://textual.textualize.io/guide

import os
import getpass

from flask_bcrypt import Bcrypt
bcrypt = Bcrypt()

from time import sleep

from rich.console import RenderableType
from rich.markdown import Markdown
from rich.syntax import Syntax
from rich.traceback import Traceback

from textual import on, work
from textual.screen import Screen
from textual.app import App, ComposeResult
from textual.containers import Horizontal, Container, VerticalScroll, Center, ScrollableContainer
from textual.reactive import var, reactive
from textual.binding import Binding
from textual.screen import ModalScreen
from textual.widgets import (
    Button,
    DirectoryTree,
    Footer,
    Header,
    Static,
    Label,
    MarkdownViewer,
    Switch,
    RichLog,
    Input
)

"""
    __BACKBATCH_USER_DATA__: Guide

    > Will be encrypted with Bcrypt
    [USERNAME, PASSWORD, RANK, [LIST OF COMPUTER USERS THAT CAN ACCESS ACCOUNT]]

    Different roles: Owner(only 1k0de), Admin(Specific Users), Banned(for banned accounts)
    if inside of the coputer users list there is a value called: __any__, any once logged into a comnputer can log into that account.

    Example (uncrypted):
    ['1k0de', 'test_pass', 'Owner', ['karim.dalati1', 'adeld', 'ADEL-HP']]

    How to encode/encrypt a string (Run this in python):
    from flask_bcrypt import Bcrypt
    bcrypt = Bcrypt()
    bcrypt.generate_password_hash('to_encode').decode('utf-8') -> What ever this returns is the encode/encrypted string.
    (Note: everytime you hash a password, even if its the same one, it will return a different result)

    Comparing credentials (For login):
    bcrypt.check_password_hash(ENCODED_CREDENTIAL, 'TO_COMAPRE') -> Returns a BOOLEAN (True/False), Use in IF statement
"""

__BACKBATCH_USER_DATA__ = [
    [
        "$2b$12$E8Vfd312u2a8vN8QtVWZ/uPUgNDDmkXkksNRkshW0GxwOLkEB.csO",
        "$2b$12$mWL/nxVFripa2dk6sG/S..3uIS7ziwbFhAbugDFKqdzNS0Btq6ObG",
        "$2b$12$zQSM7f19/NF1NIhKB.gZ4uTwXhWQf0qRiGkuXaL69.asdl5UhvfJi",
        [
            "$2b$12$ZcvlL2bOQkwMjvIwVvRgReGFGRS0h6C/X1OCwNIZsP360RqWmvN6y",
            "$2b$12$yK9OzGXj5Ric8B57O8QonuP4P//Z668QCFrzrD2qQ7R2L9DqCGUTu",
            "$2b$12$NDN7EXIgxGewVpugR0j/Tu8e0Qu8lkpfDH2S/LToxJ32dADHq.RZu"
        ]
    ],
    [
        "$2b$12$zGPQ4OLKqpwl79uW7cc/bu7F243DREndvVluZvxYWDMdXvlRhSMzy", #test_guy account
        "$2b$12$qO/ngYd.T.iCLLezy0bR7uR9XBy/mUrw5RegSmd4nGCpUuUf64yHi", #password: test_pass
        "$2b$12$PUHBTu4CrUpIqJPKMYEw6eSmVAkr1t.lqhte3Ivn.YgBmr73tU9sC",
        [
            "$2b$12$Fb1dqrO.mXRfr085kzog0.WHFwF/LFMFd9Q48YpRjXvp7i9IOE.1C"
        ]
    ],
    [
        "$2b$12$jzWimrhkWqJIbDn3dB.J7.ul7iE3RHL3NveEvL/I.ruZZxlIgNBiO",
        "$2b$12$xXUr2Tti9DsnJyUb79OrVeXbKlXf0Nc//rsGFQVnzdOwaZBZ0CG06",
        "$2b$12$llw89h2rf0lirkB/zLWso.AgtbKYgpbtzfBhzQ8S02xYB5AgIxC52",
        [
            "$2b$12$aX45re38X9Wr9SjCvvv5W..ah5jhTdq0jKhAR/3YYUnmCln8U71lG",
            "$2b$12$WTPQ65uPnfulGYAPGT7kEeVGDb.2eZ7tgO559g59GgVachko5vptC"
        ],
    ],
    [
        "$2b$12$Esa98rP8D6OQxZdRjDMMQ.M8ZsxdmZXr.Bj/7ATWZJKcroGcoUFHi",
        "$2b$12$HuyTNS.y3X02CUPR6k61Behyz/9db2ZyDFkthbS6/4mUhha7uBeum",
        "$2b$12$llw89h2rf0lirkB/zLWso.AgtbKYgpbtzfBhzQ8S02xYB5AgIxC52",
        [
            "$2b$12$48LcNqSvq9rG6xWIU.XbHeYaw6bXyIZu0GHqwbF.e5E7P54GptCZi",
            "$2b$12$WTPQ65uPnfulGYAPGT7kEeVGDb.2eZ7tgO559g59GgVachko5vptC"
        ],
    ]
]

WELCOME_MD = """

## Back Batch - Master

Please login to use BackBatch.
"""

LOGIN_MD = """

Welcome to BackBatch Login.
You may only use this app if you have been given an account.
"""

UPDATES_MD = """

- Added snap shot command.
- Added notification command.
- Improved message command.
- Stoped using files to communicate. (Better and more efficient performance)
- New GUI rather than CLI.
"""

SIDE_BAR_MESSAGE = """
BackBatch is a program created by 1k0de to remotely perform tasks on other peoples device.

"""

BB_START_SCREEN_CSS = """
* {
    transition: background 500ms in_out_cubic, color 500ms in_out_cubic;
}

Screen {
    layers: base overlay notes notifications;
    overflow: hidden;
}


Notification {
    dock: bottom;
    layer: notification;
    width: auto;
    margin: 2 4;
    padding: 1 2;
    background: $background;
    color: $text;
    height: auto;

}

Sidebar {
    width: 40;
    background: $panel;
    transition: offset 500ms in_out_cubic;
    layer: overlay;

}

Sidebar:focus-within {
    offset: 0 0 !important;
}

Sidebar.-hidden {
    offset-x: -100%;
}

Sidebar Title {
    background: $boost;
    color: $secondary;
    padding: 2 4;
    border-right: vkey $background;
    dock: top;
    text-align: center;
    text-style: bold;
}


OptionGroup {
    background: $boost;
    color: $text;
    height: 1fr;
    border-right: vkey $background;
}

Option {
    margin: 1 0 0 1;
    height: 3;
    padding: 1 2;
    background: $boost;
    border: tall $panel;
    text-align: center;
}

Option:hover {
    background: $primary 20%;
    color: $text;
}

Body {
    height: 100%;
    overflow-y: scroll;
    width: 100%;
    background: $surface;

}

AboveFold {
    width: 100%;
    height: 100%;
    align: center middle;
}

Welcome {
    background: $boost;
    height: auto;
    max-width: 100;
    min-width: 40;
    border: wide $primary;
    padding: 1 2;
    margin: 1 2;
    box-sizing: border-box;
}

Welcome Button {
    width: 100%;
    margin-top: 1;
}

Column {
    height: auto;
    min-height: 100vh;
    align: center top;
    overflow: hidden;
}


DarkSwitch {
    background: $panel;
    padding: 1;
    dock: bottom;
    height: auto;
    border-right: vkey $background;
}

DarkSwitch .label {
    width: 1fr;
    padding: 1 2;
    color: $text-muted;
}

DarkSwitch Switch {
    background: $boost;
    dock: left;
}


Screen>#c_main {
    height: 100%;
    overflow: hidden;
}

Section {
    height: auto;
    min-width: 40;
    margin: 1 2 4 2;

}

Section > #last_exit_btn {
    width: 100%;
}

SectionTitle {
    padding: 1 2;
    background: $boost;
    text-align: center;
    text-style: bold;
}

SubTitle {
    padding-top: 1;
    border-bottom: heavy $panel;
    color: $text;
    text-style: bold;
}

TextContent {
    margin: 1 0;
}

QuickAccess {
    width: 30;
    dock: left;

}

LocationLink {
    margin: 1 0 0 1;
    height: 1;
    padding: 1 2;
    background: $boost;
    color: $text;
    box-sizing: content-box;
    content-align: center middle;
}

LocationLink:hover {
    background: $accent;
    color: $text;
    text-style: bold;
}


.pad {
    margin: 1 0;
}

DataTable {
    height: 16;
    max-height: 16;
}


LoginForm {
    height: auto;
    margin: 1 0;
    padding: 1 2;
    layout: grid;
    grid-size: 2;
    grid-rows: 4;
    grid-columns: 12 1fr;
    background: $boost;
    border: wide $background;
}

LoginForm Button {
    margin: 0 1;
    width: 100%;
}

LoginForm .label {
    padding: 1 2;
    text-align: right;
}

Message {
    margin: 0 1;

}


Tree {
    margin: 1 0;
}


Window {
    background: $boost;
    overflow: auto;
    height: auto;
    max-height: 16;
}

Window>Static {
    width: auto;
}


Version {
    color: $text-disabled;
    dock: bottom;
    text-align: center;
    padding: 1;
}

"""

DASHBOARD_CSS = """
Screen {
    background: $surface-darken-1;
}

#tree-view {
    display: none;
    scrollbar-gutter: stable;
    overflow: auto;
    width: auto;
    height: 100%;
    dock: left;
}

CodeBrowser.-show-tree #tree-view {
    display: block;
    max-width: 50%;
}


#code-view {
    overflow: auto scroll;
    min-width: 100%;
}
#code {
    width: auto;
}

"""

## FOR SCREENS SUPPORT, USE: https://textual.textualize.io/guide/screens/

class ExitScreen(ModalScreen):
    """A modal exit screen."""

    DEFAULT_CSS = """
    ExitScreen {
        align: center middle;
    }

    ExitScreen > Container {
        width: auto;
        height: auto;
        border: thick $background 80%;
        background: $surface;
    }

    ExitScreen > Container > Label {
        width: 100%;
        content-align-horizontal: center;
        margin-top: 1;
    }

    ExitScreen > Container > Horizontal {
        width: auto;
        height: auto;
    }

    ExitScreen > Container > Horizontal > Button {
        margin: 2 4;
    }
    """

    def compose(self) -> ComposeResult:
        with Container():
            yield Label("Are you sure you want to quit?")
            with Horizontal():
                yield Button("No", id="no", variant="error")
                yield Button("Yes", id="yes", variant="success")

    @on(Button.Pressed, "#yes")
    def exit_app(self) -> None:
        self.app.exit("")

    @on(Button.Pressed, "#no")
    def back_to_app(self) -> None:
        self.app.pop_screen()


class Body(ScrollableContainer):
    pass

class Title(Static):
    pass

class Welcome(Container):
    def compose(self) -> ComposeResult:
        yield Static(Markdown(WELCOME_MD))
        yield Button("Login", variant="success")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.app.query_one(".location-login").scroll_visible(duration=0.5, top=True)

class OptionGroup(Container):
    pass

class SectionTitle(Static):
    pass

class Message(Static):
    pass

class Version(Static):
    def render(self) -> RenderableType:
        return "[b]v2.0.1"

class DarkSwitch(Horizontal):
    def compose(self) -> ComposeResult:
        yield Switch(value=self.app.dark)
        yield Static("Dark mode toggle", classes="label")

    def on_mount(self) -> None:
        self.watch(self.app, "dark", self.on_dark_change, init=False)

    def on_dark_change(self) -> None:
        self.query_one(Switch).value = self.app.dark

    def on_switch_changed(self, event: Switch.Changed) -> None:
        self.app.dark = event.value

class Sidebar(Container):
    def compose(self) -> ComposeResult:
        yield Title("Back Batch")
        yield OptionGroup(Message(SIDE_BAR_MESSAGE), Version())
        yield DarkSwitch()

class AboveFold(Container):
    pass


class Section(Container):
    pass


class Column(Container):
    pass


class TextContent(Static):
    pass


class QuickAccess(Container):
    pass

class LocationLink(Static):
    def __init__(self, label: str, reveal: str) -> None:
        super().__init__(label)
        self.reveal = reveal

    def on_click(self) -> None:
        self.app.query_one(self.reveal).scroll_visible(top=True, duration=0.5)

class Window(Container):
    pass


class SubTitle(Static):
    pass

class Dashboard(Screen):
    CSS = DASHBOARD_CSS

    show_tree = var(True)

    def watch_show_tree(self, show_tree: bool) -> None:
        """Called when show_tree is modified."""
        self.set_class(show_tree, "-show-tree")

    def compose(self) -> ComposeResult:
        """Compose our UI."""
        path = "./" if len(sys.argv) < 2 else sys.argv[1]
        yield Header()
        with Container():
            yield DirectoryTree(path, id="tree-view")
            with VerticalScroll(id="code-view"):
                yield Static(id="code", expand=True)
        yield Footer()

    def on_mount(self) -> None:
        self.query_one(DirectoryTree).focus()

    def on_directory_tree_file_selected(
        self, event: DirectoryTree.FileSelected
    ) -> None:
        """Called when the user click a file in the directory tree."""
        event.stop()
        code_view = self.query_one("#code", Static)
        try:
            syntax = Syntax.from_path(
                str(event.path),
                line_numbers=True,
                word_wrap=False,
                indent_guides=True,
                theme="github-dark",
            )
        except Exception:
            code_view.update(Traceback(theme="github-dark", width=None))
            self.sub_title = "ERROR"
        else:
            code_view.update(syntax)
            self.query_one("#code-view").scroll_home(animate=False)
            self.sub_title = str(event.path)

    def action_toggle_files(self) -> None:
        """Called in response to key binding."""
        self.show_tree = not self.show_tree

class LoginForm(Container):

    def compose(self) -> ComposeResult:
        yield Static("Username", classes="label")

        self._usernameBox = Input(placeholder="Username")
        yield self._usernameBox

        yield Static("Password", classes="label")

        self._passwordBox = Input(placeholder="Password", password=True)
        yield self._passwordBox

        yield Static()
        yield Button("Login", variant="primary")

    @on(Button.Pressed)
    @work(thread=True)
    async def process_login_info(self, event: Button.Pressed) -> None:
        event.button.disabled = True
        event.button.label = "Logging In..."

        CAN_PASS = False
        RANK = ""

        if self._usernameBox.value == "":
            self.notify("Username cannot be empty.", severity="error")
            event.button.label = "Login"
            event.button.disabled = False
            return
        
        if self._passwordBox.value == "":
            self.notify("Password cannot be empty.", severity="error")
            event.button.label = "Login"
            event.button.disabled = False
            return
        
        self.notify("Checking account details...", severity="warning")

        CURRENT_COMPUTER_USERNAME = getpass.getuser()
         
        for account in __BACKBATCH_USER_DATA__:
            try:
                if bcrypt.check_password_hash(account[0], self._usernameBox.value) == True:
                    if bcrypt.check_password_hash(account[1], self._passwordBox.value) == True:
                        if bcrypt.check_password_hash(account[2], "Banned"):
                            self.notify("This account is banned.", severity="error")
                            event.button.label = "Login"
                            event.button.disabled = False
                            return
                        if bcrypt.check_password_hash(account[2], "Admin"):
                            RANK = "Admin"
                        if bcrypt.check_password_hash(account[2], "Owner"):
                            RANK = "Owner"
                        
                        for computer_user in account[3]:
                            if bcrypt.check_password_hash(computer_user, CURRENT_COMPUTER_USERNAME):
                                CAN_PASS = True

                        if CAN_PASS == False:
                            self.notify("You don't have permission to use this account.", severity="error")
                            event.button.label = "Login"
                            event.button.disabled = False
                            return
                else:
                    pass # Skip to the next loop
            except:
                self.notify("Invalid account.", severity="error")
                event.button.disabled = False
                return
            
        if CAN_PASS == True:
            self.notify("Successfully logged in.", severity="information")
            event.button.label = "Login"
            event.button.disabled = False
            await self.app.post_message(Message("goto_dash"))
        else:
            self.notify("Incorrect username or password.", severity="error")
            event.button.label = "Login"
            event.button.disabled = False

class BackBatch(Screen):
    CSS = BB_START_SCREEN_CSS
    TITLE = "BackBatch | Master"
    BINDINGS = [
        ("ctrl+b", "toggle_sidebar", "Sidebar"),
        ("ctrl+q", "exit_app", "Quit app")
    ]

    show_sidebar = reactive(False)

    def compose(self) -> ComposeResult:
        example_css = BB_START_SCREEN_CSS
        yield Container(
            Sidebar(classes="-hidden"),
            Header(show_clock=False),
            RichLog(classes="-hidden", wrap=False, highlight=True, markup=True),
            Body(
                QuickAccess(
                    LocationLink("Splash Screen", ".location-top"),
                    LocationLink("Login", ".location-login"),
                    LocationLink("Updates", ".location-updates"),
                ),
                AboveFold(Welcome(), classes="location-top"),
                Column(
                    Section(
                        SectionTitle("BackBatch Login"),
                        TextContent(Markdown(LOGIN_MD)),
                        LoginForm(),
                    ),
                    classes="location-login location-first",
                ),
                Column(
                    Section(
                        SectionTitle("Updates"),
                        TextContent(Markdown(UPDATES_MD)),
                        Button("Exit App", variant="error", id="last_exit_btn")
                    ),
                    classes="location-updates"
                )
            ),
            id="c_main"
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("Welcome Button", Button).focus()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "last_exit_btn":
            self.app.exit("")

    def action_toggle_sidebar(self) -> None:
        sidebar = self.query_one(Sidebar)
        self.set_focus(None)
        if sidebar.has_class("-hidden"):
            sidebar.remove_class("-hidden")
        else:
            if sidebar.query("*:focus"):
                self.screen.set_focus(None)
            sidebar.add_class("-hidden")


class bb_handler(App):
    BINDINGS = [
        ("ctrl+q", "exit_app", "Quit app")
    ]
    
    SCREENS = {
        "start": BackBatch(),
        "dashboard": Dashboard(),
        "exit_prompt": ExitScreen()
    }

    def on_mount(self) -> None:
        self.push_screen("start")

    def action_exit_app(self) -> None:
        self.push_screen("exit_prompt")

    def on_goto_dash(self) -> None:
        self.switch_screen("dashboard")
        

if __name__ == "__main__":
    os.system("title Back Batch - Master")
    app = bb_handler()
    app.run()
