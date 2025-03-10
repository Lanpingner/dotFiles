-- Base
import XMonad
import XMonad.Config.Desktop
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow ((&&&),first)

    -- Data
import Data.List
import Data.Monoid
import Data.Maybe (isJust)
import qualified Data.Map as M

    -- Utilities
import XMonad.Util.Loggers
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Layout.IndependentScreens

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, wrap, pad, xmobarPP, xmobarColor, shorten, PP(..), ppOutput)
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat)
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops   -- required for xcomposite in obs to work
import XMonad.Hooks.DynamicBars
    
    -- Actions
import XMonad.Actions.Minimize (minimizeWindow)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.MouseResize
import qualified XMonad.Actions.ConstrainedResize as Sqr

    -- Layouts modifiers
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.NoBorders
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.OneBig
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import XMonad.Layout.IM (withIM, Property(Role))

------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------

myFont        = "xft:Meslo Nerd font:regular:pixelsize=11"

myModMask     = mod4Mask     -- Sets modkey to super/windows key

myTerminal    = "xterm"  -- Sets default terminal

myTextEditor  = "vim"       -- Sets default text editor

myBorderWidth = 2            -- Sets border width for windows

myNormColor   = "#292d3e"    -- Border color of normal windows

myFocusColor  = "#FF00FF"    -- Border color of focused windows

altMask       = mod4Mask     -- Setting this for use in xprompts

windowCount   = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset



------------------------------------------------------------------------
-- AUTOSTART
------------------------------------------------------------------------

myStartupHook = do

          spawnOnce "nitrogen --restore &"
         -- spawnOnce "picom &"
          spawnOnce "nm-applet &"
         -- spawnOnce "volumeicon &"
          spawnOnce "setxkbmap us"
        --  spawnOnce "redshift"
          --spawnOnce "/usr/bin/emacs --daemon &"
      --    spawnOnce "xfsettingsd"
------------------------------------------------------------------------
-- GRID SELECT
------------------------------------------------------------------------

myColorizer :: Window -> Bool -> X (String, String)

myColorizer = colorRangeFromClassName

                  (0x31,0x2e,0x39) -- lowest inactive bg
                  (0x31,0x2e,0x39) -- highest inactive bg
                  (0x61,0x57,0x72) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0xff,0xff,0xff) -- active fg

-- gridSelect menu layout
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 30
    , gs_cellwidth    = 200
    , gs_cellpadding  = 8
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }


spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = defaultGSConfig

------------------------------------------------------------------------
-- XPROMPT KEYMAP (emacs-like key bindings)
------------------------------------------------------------------------

dtXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
dtXPKeymap = M.fromList $
     map (first $ (,) controlMask)   -- control + <key>
     [ (xK_z, killBefore)            -- kill line backwards
     , (xK_k, killAfter)             -- kill line fowards
     , (xK_a, startOfLine)           -- move to the beginning of the line
     , (xK_e, endOfLine)             -- move to the end of the line
     , (xK_m, deleteString Next)     -- delete a character foward
     , (xK_b, moveCursor Prev)       -- move cursor forward
     , (xK_f, moveCursor Next)       -- move cursor backward
     , (xK_BackSpace, killWord Prev) -- kill the previous word
     , (xK_y, pasteString)           -- paste a string
     , (xK_g, quit)                  -- quit out of prompt
     , (xK_bracketleft, quit)
     ]
     ++
     map (first $ (,) altMask)       -- meta key + <key>
     [ (xK_BackSpace, killWord Prev) -- kill the prev word
     , (xK_f, moveWord Next)         -- move a word forward
     , (xK_b, moveWord Prev)         -- move a word backward
     , (xK_d, killWord Next)         -- kill the next word
     , (xK_n, moveHistory W.focusUp')   -- move up thru history
     , (xK_p, moveHistory W.focusDown') -- move down thru history
     ]
     ++

     map (first $ (,) 0) -- <key>

     [ (xK_Return, setSuccess True >> setDone True)

     , (xK_KP_Enter, setSuccess True >> setDone True)

     , (xK_BackSpace, deleteString Prev)

     , (xK_Delete, deleteString Next)

     , (xK_Left, moveCursor Prev)

     , (xK_Right, moveCursor Next)

     , (xK_Home, startOfLine)

     , (xK_End, endOfLine)

     , (xK_Down, moveHistory W.focusUp')

     , (xK_Up, moveHistory W.focusDown')

     , (xK_Escape, quit)

     ]



------------------------------------------------------------------------
-- KEYBINDINGS
------------------------------------------------------------------------

myKeys =

    -- Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")      -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")        -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                  -- Quits xmonad
        , ("M-S-g", goToSelected $ mygridConfig myColorizer)  -- goto selected
        --, ("M-S-t", spawn "rofi -show drun")  -- goto selected
    -- Prompts
        -- The next three bindings require pass to be installed
        --, ("M1-C-p", passPrompt dtXPConfig)          -- Get Passwords Prompt
        --, ("M1-C-g", passGeneratePrompt dtXPConfig)  -- Generate Passwords Prompt
        --, ("M1-C-r", passRemovePrompt dtXPConfig)    -- Remove Passwords Prompt

     --audio
        , ("<XF86AudioMute>", spawn "amixer set Master toggle && amixer set Speaker toggle")        --toggle volume
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 10%-")          --decrease volume
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 10%+")          --increase volume
        , ("M-S-l", spawn "i3lock -c 000000") --lock the screen

        --backlight
        , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")        --increase brightness 
        , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10")        --increase brightness 

    -- Windows
        , ("M-S-c", kill1)                           -- Kill the currently focused client
        , ("M-S-a", killAll)                         -- Kill all the windows on current workspace

    -- Floating windows

        , ("M-t", withFocused $ windows . W.sink) -- Push floating window back to tile.
        , ("M-S-<Delete>", sinkAll)                      -- Push ALL floating windows back to tile.


    -- Grid Select
         , (("M-S-t"), spawnSelected'
          [ ("Telegram", "telegram-desktop")
           , ("Joplin", "JoplinDesktop.AppImage")
           , ("Chromium", "chromium")
           , ("Firefox", "firefox-developer-edition")
           , ("Whatsapp", "surf https://web.whatsapp.com/")
           , ("Ferdi", "ferdi")
           , ("Thunderbird", "thunderbird")
           , ("LibreOffice Writer", "lowriter")
           , ("Brave", "brave")
           , ("steam", "steam")
           --, ("redshift",    "redshift")
           , ("KeepassXC",    "keepassxc")
           , ("Xrandr Dock","xrandr --output DP2-3 --right-of eDP1 --mode 1440x900 && feh --bg-center /home/artix-safeguard/Pictures/Walls/ZeroVsOmega.png --bg-fill /home/artix-safeguard/Pictures/Walls/TPP.jpg")
           , ("Xrandr Off","xrandr --output DP2-3 --off ")
           , ("Lf","terminator -e lf")
 ])
 ,("M-S-g", goToSelected $ mygridConfig myColorizer)  -- goto selected

 -- Windows navigation
 , ("M-m", windows W.focusMaster)             -- Move focus to the master window
 , ("M-j", windows W.focusDown)               -- Move focus to the next window
 , ("M-k", windows W.focusUp)                 -- Move focus to the prev window
 --, ("M-S-m", windows W.swapMaster)            -- Swap the focused window and the master window
 , ("M-S-j", windows W.swapDown)              -- Swap the focused window with the next window
 , ("M-S-k", windows W.swapUp)                -- Swap the focused window with the prev window
 , ("M-<Backspace>", promote)                 -- Moves focused window to master, all others maintain order
 , ("M1-S-<Tab>", rotSlavesDown)              -- Rotate all windows except master and keep focus in place
 , ("M1-C-<Tab>", rotAllDown)                 -- Rotate all the windows in the current stack
 , ("M-C-s", killAllOtherCopies)
 , ("M-<Up>", sendMessage (MoveUp 10))             --  Move focused window to up
 , ("M-<Down>", sendMessage (MoveDown 10))         --  Move focused window to down
 , ("M-<Right>", sendMessage (MoveRight 10))       --  Move focused window to right
 , ("M-<Left>", sendMessage (MoveLeft 10))         --  Move focused window to left
 , ("M-S-<Up>", sendMessage (IncreaseUp 10))       --  Increase size of focused window up
 , ("M-S-<Down>", sendMessage (IncreaseDown 10))   --  Increase size of focused window down
 , ("M-S-<Right>", sendMessage (IncreaseRight 10)) --  Increase size of focused window right
 , ("M-S-<Left>", sendMessage (IncreaseLeft 10))   --  Increase size of focused window left
 , ("M-C-<Up>", sendMessage (DecreaseUp 10))       --  Decrease size of focused window up
 , ("M-C-<Down>", sendMessage (DecreaseDown 10))   --  Decrease size of focused window down
 , ("M-C-<Right>", sendMessage (DecreaseRight 10)) --  Decrease size of focused window right
 , ("M-C-<Left>", sendMessage (DecreaseLeft 10))   --  Decrease size of focused window left


 -- Layouts
 , ("M-<Tab>", sendMessage NextLayout)                                -- Switch to next layout
 , ("M-S-<Space>", sendMessage ToggleStruts)                          -- Toggles struts
 , ("M-S-n", sendMessage $ Toggle NOBORDERS)                          -- Toggles noborder
 , ("M-S-=", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
 , ("M-S-f", sendMessage (T.Toggle "float"))
 , ("M-S-x", sendMessage $ Toggle REFLECTX)
 , ("M-S-y", sendMessage $ Toggle REFLECTY)
 , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in the master pane
 , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in the master pane
 , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase number of windows that can be shown
 , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease number of windows that can be shown
 , ("M-h", sendMessage Shrink)
 , ("M-l", sendMessage Expand)
 , ("M-C-j", sendMessage MirrorShrink)
 , ("M-C-k", sendMessage MirrorExpand)
 , ("M-S-;", sendMessage zoomReset)
 , ("M-;", sendMessage ZoomFullToggle)

 -- Workspaces
 , ("M-.", nextScreen)                           -- Switch focus to next monitor
 , ("M-,", prevScreen)                           -- Switch focus to prev monitor
 , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next workspace
 , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to previous workspace

 --to run the terminal, dmenu, and dmusick:
 , ("M-<Return>", spawn (myTerminal))
 --, ("M-p", spawn "dmenu_run")
 , ("M-p", spawn "rofi -show drun -width 100 -padding 800 -lines 5 -columns 2 -bw 0 -eh 1")
 , ("M-S-p", spawn "dmusick")

 ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))

	 nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))


------------------------------------------------------------------------
-- WORKSPACES
------------------------------------------------------------------------

-- My workspaces are clickable meaning that the mouse can be used to switch
-- workspaces. This requires xdotool.

xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
	--workspaces. I've put number and an icon to save space and to have a better idea when sending windows to a workspace.
myWorkspaces = clickable . (map xmobarEscape)
               $ ["1:\xf120 ", "2:\xf269 ", "3:\xf268 ", "4:\xf1b6 ", "5:\xf069 ", "6:\xf0c0 ", "7:\xf07c ", "8:\xf2cd ", "9:\xf084 /\xf0e0 "]

  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

------------------------------------------------------------------------
-- MANAGEHOOK
------------------------------------------------------------------------
-- Sets some rules for certain programs. Examples include forcing certain
-- programs to always float, or to always appear on a certain workspace.
-- Forcing programs to a certain workspace with a doShift requires xdotool
-- if you are using clickable workspaces. You need the className or title
-- of the program. Use xprop to get this info.

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out
     -- the full name of my clickable workspaces, which would look like:
     -- doShift "<action xdotool super+8>gfx</action>"

    [
      title =? "firefox-developer-edition"     --> doShift ( myWorkspaces !! 2)
      ,className =? "mpv"     --> doShift ( myWorkspaces !! 5)
      ,className =? "vlc"     --> doShift ( myWorkspaces !! 5)
      ,className =? "Gimp"    --> doFloat
      ,className =? "Brave"     --> doShift ( myWorkspaces !! 3)
      ,title =? "Oracle VM VirtualBox Manager"     --> doFloat

      ,(className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog

     ] 
-- LAYOUTS
------------------------------------------------------------------------

myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ myDefaultLayout
             where
                 myDefaultLayout = space ||| tall ||| grid ||| threeCol ||| threeRow ||| oneBig ||| noBorders monocle ||| floats


tall     = renamed [Replace "tall"]     $ limitWindows 12 $ spacing 6 $ ResizableTall 1 (3/100) (1/2) []
grid     = renamed [Replace "grid"]     $ limitWindows 12 $ spacing 6 $ mkToggle (single MIRROR) $ Grid (16/10)
threeCol = renamed [Replace "threeCol"] $ limitWindows 3  $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"] $ limitWindows 3  $ Mirror $ mkToggle (single MIRROR) zoomRow
oneBig   = renamed [Replace "oneBig"]   $ limitWindows 6  $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (5/9) (8/12)
monocle  = renamed [Replace "monocle"]  $ limitWindows 20 $ Full

space    = renamed [Replace "space"]    $ limitWindows 4  $ spacing 12 $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (2/3) (2/3)
floats   = renamed [Replace "floats"]   $ limitWindows 20 $ simplestFloat



------------------------------------------------------------------------
-- MAIN
------------------------------------------------------------------------

main = do
    -- Launch xmobars on their monitors.

    xmproc <- spawnPipe ("xmobar -x 0  /home/romeo/.config/xmobar/xmbar0")
    --xmproc <- spawnPipe ("xmobar -x 1  /home/artix-safeguard/.config/xmobar/xmobarrc1")

    xmonad $ ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageHook desktopConfig <+> manageDocks
         ,modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor "#c3e88d" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#F07178" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#d0d0d0" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
        } `additionalKeysP` myKeys
