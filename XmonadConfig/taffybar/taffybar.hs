-- https://github.com/taffybar/taffybar/blob/master/taffybar.hs.example as of 2019-01-27

-- -*- mode:haskell -*-
{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Taffybar
import System.Taffybar.Context hiding (startWidgets, endWidgets, widgetSpacing)
import System.Taffybar.Hooks
import System.Taffybar.Information.CPU
import System.Taffybar.Information.CPU2
import System.Taffybar.Information.Memory
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget
import System.Taffybar.Widget.Battery
import System.Taffybar.Widget.CommandRunner
import System.Taffybar.Widget.FreedesktopNotifications
import System.Taffybar.Widget.Generic.PollingGraph
import System.Taffybar.Widget.Generic.PollingLabel
import System.Taffybar.Widget.Text.NetworkMonitor
import System.Taffybar.Widget.Util
import System.Taffybar.Widget.Windows
import System.Taffybar.Widget.Workspaces

import qualified GI.Gtk as Gtk
import qualified Data.Text as T

transparent = (0.0, 0.0, 0.0, 0.0)
yellow1 = (0.9453125, 0.63671875, 0.2109375, 1.0)
yellow2 = (0.9921875, 0.796875, 0.32421875, 1.0)
green1 = (0, 1, 0, 1)
green2 = (1, 0, 1, 0.5)
taffyBlue = (0.129, 0.588, 0.953, 1)

myGraphConfig =
  defaultGraphConfig
  { graphPadding = 0
  , graphBorderWidth = 0
  , graphWidth = 30
  , graphBackgroundColor = transparent
  }

memCfg = myGraphConfig
  { graphDataColors = [taffyBlue]
  , graphLabel = Just "mem"
  }

cpuCfg = myGraphConfig
  { graphDataColors = [green1, green2]
  , graphLabel = Just "cpu"
  }

memCallback :: IO [Double]
memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (_, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

main = do
  let myWorkspacesConfig =
        defaultWorkspacesConfig
        { minIcons = 1
        , widgetGap = 0
        , showWorkspaceFn = hideEmpty
        }
      workspaces = workspacesNew myWorkspacesConfig
      cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
      mem = pollingGraphNew memCfg 1 memCallback
      net = networkMonitorNew defaultNetFormat $ Just ["eth2", "wlan2"]
      clock = textClockNew Nothing "%a %b %_d %T" 1
      layout = layoutNew defaultLayoutConfig
      windows = windowsNew defaultWindowsConfig { getMenuLabel = truncatedGetMenuLabel 30 }
          -- See https://github.com/taffybar/gtk-sni-tray#statusnotifierwatcher
          -- for a better way to set up the sni tray
      tray = sniTrayThatStartsWatcherEvenThoughThisIsABadWayToDoIt
      bar = do
         label <- Gtk.labelNew (Just "|" :: Maybe T.Text)
         Gtk.widgetShowAll label
         Gtk.toWidget label :: TaffyIO Gtk.Widget
      myConfig = defaultSimpleTaffyConfig
        { startWidgets =
            (clock >>= buildContentsBox)
            : (bar >>= buildContentsBox)
            : workspaces
            : map (>>= buildContentsBox) [ layout, bar, commandRunnerNew 1.0 "emacs-current-task" [] "…", bar, windows ]
        , endWidgets = map (>>= buildContentsBox)
          [ textBatteryNew "$percentage$% ($status$)"
          , tray
          , cpu
          , mem
          , net
          , notifyAreaNew defaultNotificationConfig
          ]
        , barPosition = Top
        , barHeight = 18
        , widgetSpacing = 0
        }
  dyreTaffybar $ withBatteryRefresh $ withLogServer $ withToggleServer $ toTaffyConfig myConfig
