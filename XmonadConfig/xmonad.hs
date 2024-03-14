-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config
import Graphics.X11.ExtraTypes.XF86

import Data.Tree

import System.IO
import System.Exit

import XMonad
import XMonad.Config

import XMonad.Actions.SpawnOn
import XMonad.Actions.CycleWS
import XMonad.Actions.Minimize (minimizeWindow)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.GridSelect
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.MouseResize
import XMonad.Actions.GridSelect
import qualified XMonad.Actions.ConstrainedResize as Sqr
import qualified XMonad.Actions.TreeSelect as TS

import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow ((&&&),first)


import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.TaffybarPagerHints (pagerHints)

import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Mosaic
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Simplest
import XMonad.Layout.Accordion
import XMonad.Layout.Magnifier
import XMonad.Layout.OneBig
import XMonad.Layout.DecorationMadness
import XMonad.Layout.ResizableTile
import XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import XMonad.Layout.IM (withIM, Property(Role))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.Spacing
--import Xmonad.Layout.LayoutModifier 
import XMonad.Layout.LayoutModifier
import XMonad.Layout.ShowWName
import XMonad.Layout.WindowNavigation
import XMonad.Layout.SubLayouts

import XMonad.Operations


import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP)
import XMonad.Util.SpawnOnce
import XMonad.Util.NamedScratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Prompt
import XMonad.Prompt.RunOrRaise (runOrRaisePrompt)
import XMonad.Prompt.AppendFile (appendFilePrompt)

import Data.Maybe (isJust)

myTerminal = "alacritty"
--Some Haskel Fun
--windowCount :: Integer
--windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


------------------------------------------------------------------------
-- Workspace
------------------------------------------------------------------------
myWorkspaces = ["1:Term","2:Web","3:im","4:Oracle","5:media","6:<fn=3>\xf17c</fn>"] ++ map show [7..9]

------------------------------------------------------------------------
-- End Workspaces
------------------------------------------------------------------------

colorScheme = "doom-one"

colorBack = "#282c34"
colorFore = "#bbc2cf"

color01 = "#1c1f24"
color02 = "#ff6c6b"
color03 = "#98be65"
color04 = "#da8548"
color05 = "#51afef"
color06 = "#c678dd"
color07 = "#5699af"
color08 = "#202328"
color09 = "#5b6268"
color10 = "#da8548"
color11 = "#4db5bd"
color12 = "#ecbe7b"
color13 = "#3071db"
color14 = "#a9a1e1"
color15 = "#46d9ff"
color16 = "#dfdfdf"

colorTrayer :: String
colorTrayer = "--tint 0x282c34"

------------------------------------------------------------------------
-- Window rules
------------------------------------------------------------------------
myManageHook = composeAll
    [ title =? "firefox-developer-edition"     --> doShift "2:web"
--    , title =? "Android Emulator - Pixel_6_API_31:5554" --> doFloat
    , className =? "Chromium"       --> doShift "2:web"
    , className =? "Google-chrome"  --> doShift "2:web"
    , className =? "skype"          --> doShift "3:im"
    , className =? "pidgin"         --> doShift "3:im"
    , className =? "Icedove"        --> doShift "3:mail"
    , resource  =? "desktop_window" --> doIgnore
    , className =? "Galculator"     --> doFloat
    , className =? "gscreenshot"    --> doFloat
   -- , className =? "jetbrains-studio" --> doFloat
    , title =? "Remmina Preferences" --> doFloat
  --  , title =? "Welcome to IntelliJ IDEA" --> doFloat
    , className =? "Steam"          --> doFloat
   -- , className =? "org.remmina.Remmina"           --> doFloat
    , resource  =? "gpicview"       --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "Xchat"          --> doShift "3:im"
    , className =? "stalonetray"    --> doIgnore
    , title =? "Oracle VM VirtualBox Manager" --> doShift "4:Oracle"
    , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat 
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ] <+> namedScratchpadManageHook myScratchPads
------------------------------------------------------------------------
-- End Window Rules
------------------------------------------------------------------------

------------------------------------------------------------------------
-- ScratchPads
------------------------------------------------------------------------
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "neomutt" spawnmutt findmutt managemutt
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnmutt  = myTerminal ++ " -t neomutt -e neomutt"
    findmutt   = title =? "neomutt"
    managemutt = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

------------------------------------------------------------------------
-- End ScratchPads
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Layouts
------------------------------------------------------------------------

myTabTheme = def { fontName            = myFont
                 , activeColor         = color15
                 , inactiveColor       = color08
                 , activeBorderColor   = color15
                 , inactiveBorderColor = colorBack
                 , activeTextColor     = colorBack
                 , inactiveTextColor   = color16
                 }

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify2  = renamed [Replace "magnify2"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
          -- $ XMonad.Layout.Magnifier.magnify
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| magnify2
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion


myNormalBorderColor  = "#ffffff"
myFocusedBorderColor = "#ffffff"

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = def {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

-- Color of current window title in xmobar.
-- Used to be #00CC00
xmobarTitleColor = "#22CCDD"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 1

------------------------------------------------------------------------
-- End Layouts
------------------------------------------------------------------------

myFont :: String
myFont = "xft:Mononoki Nerd Font:bold:size=9"

colorOrange         = "#FD971F"
colorDarkGray       = "#1B1D1E"
colorPink           = "#F92672"
colorGreen          = "#A6E22E"
colorBlue           = "#66D9EF"
colorYellow         = "#E6DB74"
colorWhite          = "#CCCCC6"

colorNormalBorder   = "#CCCCC6"
colorFocusedBorder  = "#fd971f"

barFont  = "terminus"
barXFont = "inconsolata:size=20"
xftFont = "xft: inconsolata-12"

myModMask = mod4Mask


mXPConfig :: XPConfig
mXPConfig =
    def { font                  = barFont
                    , bgColor               = colorDarkGray
                    , fgColor               = colorGreen
                    , bgHLight              = colorGreen
                    , fgHLight              = colorDarkGray
                    , promptBorderWidth     = 0
                    , height                = 14
                    , historyFilter         = deleteConsecutive
                    }

-- Run or Raise Menu
largeXPConfig :: XPConfig
largeXPConfig = mXPConfig
                { font = xftFont
                , height = 16
                }

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ 
  --  Reset the layouts on the current workspace to default.
   ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Move focus to the next window.
  , ((modMask, xK_Tab),
     windows W.focusDown)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  --, ((modMask, xK_l),
 --    sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  , ((modMask , xK_Scroll_Lock ),
    spawn "setxkbmap -layout us ; xmodmap ~/.Xmodmap")

  , ((modMask .|. shiftMask, xK_Scroll_Lock),
    spawn "setxkbmap -layout gr ; xmodmap ~/.Xmodmap") 
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  ++
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myDmenuRun = "dmenu_run -g 2 -l 10"
myrofiRun  = "rofi -combi-modi window,drun,ssh -theme solarized -font \"hack 10\" -show combi -icon-theme \"Papirus\" -show-icons"

myKeysPro :: [(String, X ())]
              --General
myKeysPro = [("M-S-<Return>", spawn (myTerminal))
             ,("M-q", restart "xmonad" True)
             ,("M-S-c", kill)
             ,("M-C-s", spawn ("gscreenshot -n -s -f /home/romeo/Photos/screenshoots"))
             ,("M-l", spawn "dm-tool lock")
             -- Scratcpds
             ,("M-S-t", namedScratchpadAction myScratchPads "terminal")
             ,("M-S-m", namedScratchpadAction myScratchPads "neomutt")
             ,("M-s c", namedScratchpadAction myScratchPads "calculator")
             -- Fun with promts
             ,("M-S-s", sshPrompt def)]
             ++
            -- XF86
             [("<XF86MonBrightnessDown>", spawn "light -U 10")
             ,("<XF86MonBrightnessUp>", spawn "light -A 10")]
             ++
             --Layouts
             [
             --("M-S-<KP_Add>", addName "Move window to next WS"      $ shiftTo Next nonNSP >> moveTo Next nonNSP)
            --,("M-S-<KP_Subtract>", addName "Move window to prev WS" $ shiftTo Prev nonNSP >> moveTo Prev nonNSP)
             ("M-<Space>", sendMessage NextLayout)
	     ,("M-n", refresh) 
	     ]
             ++
            --Menus
             [("M-p", spawn (myrofiRun))
             ,("M-S-p", spawn (myDmenuRun))
             ,("M-f", treeselectAction tsDefaultConfig)]
            where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
	          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))
 

------------------------------------------------------------------------
-- Mouse bindings
------------------------------------------------------------------------
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

-----------------------------------------------------------------------
-- TreeMenu
------------------------------------------------------------------------

treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [
      Node (TS.TSNode "Apllications" "a list of programs I use often" (return ())) 
      [
         Node (TS.TSNode "Insomnia" "" (spawn "/opt/insomnia/insomnia")) []
	      ,Node (TS.TSNode "Remmina" "" (spawn "remmina -i")) []
	      ,Node (TS.TSNode "Winbox" "" (spawn "wine /home/romeo/Downloads/winbox64.exe")) []
      ]
      ,Node (TS.TSNode "Layouts" "List of Layouts" (return ())) 
      [
         Node (TS.TSNode "Tall" "" (sendMessage $ JumpToLayout "tall")) []
         ,Node (TS.TSNode "Magnify" "" (sendMessage $ JumpToLayout "magnify2")) []
         ,Node (TS.TSNode "Monocle" "" (sendMessage $ JumpToLayout "monocle")) []
         ,Node (TS.TSNode "Floats" "" (sendMessage $ JumpToLayout "floats")) []
         ,Node (TS.TSNode "Grid" "" (sendMessage $ JumpToLayout "grid")) []
         ,Node (TS.TSNode "Spirals" "" (sendMessage $ JumpToLayout "spirals")) []
         ,Node (TS.TSNode "Threecol" "" (sendMessage $ JumpToLayout "threeCol")) []
         ,Node (TS.TSNode "Threerow" "" (sendMessage $ JumpToLayout "threeRow")) []
         ,Node (TS.TSNode "Tabs" "" (sendMessage $ JumpToLayout "tabs")) []
         ,Node (TS.TSNode "Tallaccordion" "" (sendMessage $ JumpToLayout "tallAccordion")) []
         ,Node (TS.TSNode "Wideaccordion" "" (sendMessage $ JumpToLayout "wideAccordion")) []
      ]
      ,Node (TS.TSNode "Screen Setup" "" (return ())) 
      [
         Node (TS.TSNode "Latop Only" "" (spawn "/bin/bash ~/.screenlayout/LAPTOP_ONLY.sh")) []
        ,Node (TS.TSNode "External" "" (return ())) 
        [
           Node (TS.TSNode "On Left" "" (spawn "/bin/bash ~/.screenlayout/LRIGHT.sh")) []
          ,Node (TS.TSNode "On Right" "" (spawn "/bin/bash ~/.screenlayout/ERIGHT.sh")) []
        ]
         
      ]
      ,Node (TS.TSNode "System Operations" "" (return ())) 
      [
         Node (TS.TSNode "Restart" "Restart OS" (spawn "reboot now")) []
        ,Node (TS.TSNode "Shutdown" "Shutdown OS" (spawn "shutdown now")) []  
        ,Node (TS.TSNode "Logout" "Logout" (io (exitWith ExitSuccess))) []
      ]
      
   ]

tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd292d3e
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff202331)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff292d3e)
                              , TS.ts_highlight    = (0xffffffff, 0xff755999)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }
myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)]
------------------------------------------------------------------------
-- EndTreeMenu
------------------------------------------------------------------------
myStartupHook = do
 spawnOnce "killall trayer" 
 spawn ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ colorTrayer ++ " --height 22")
 --spawnOnce "taffybar"
 --spawnOnce "xembedsniproxy"
 spawnOnce "picom &"
-- spawnOnce "nitrogen --restore &"
 spawnOnce "nm-applet &"
 spawnOnce "volumeicon &"
 spawnOnce "setxkbmap us &"
 setWMName "LG3D"
-- spawnOnce "remmina -i &"


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
------------------------------------------------------------------------

main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar -x 0 /home/romeo/.config/xmobar/xmbar-dark-solar"
  xmonad $ docks $ ewmh $ pagerHints $ defaults {
      logHook = dynamicLogWithPP $
      	xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
          -- , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap
            ("[<box type=Bottom width=2 mb=2 color=" ++ colorBlue ++ ">") "</box>]"
          , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
          , ppHiddenNoWindows = xmobarColor "#F07178" ""    
          , ppHidden = xmobarColor "#82AAFF" "" . wrap "" ""   -- Hidden workspaces in xmobar               
          , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
      }
  } 

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
    manageHook         = manageDocks <+> myManageHook,
    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    --layoutHook         = smartBorders $ myLayout,
    --layoutHook         = showWName' myShowWNameTheme $ myLayoutHook,
    layoutHook         = myLayoutHook,
--    manageHook         = myManageHook,
    startupHook        = myStartupHook
    } `additionalKeysP` myKeysPro
