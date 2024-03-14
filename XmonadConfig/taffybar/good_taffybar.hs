{-# LANGUAGE OverloadedStrings #-}
import Data.Default (def)
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

data Resolution = HD | UHD
data Device     = Desktop | Laptop

cpuCallback = do
  (_, systemLoad, totalLoad) <- cpuLoad
  return [ totalLoad, systemLoad ]

main = do
  let cpuCfg = def
                 { graphDataColors = [ (0, 1, 0, 1), (1, 0, 1, 0.5)]
                 , graphLabel = Just "cpu"
                 }
      clock = textClockNewWith def
      cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
      res  = HD
      workspaces = workspacesNew def
      startW = [ workspaces ]
      endW = [ sniTrayThatStartsWatcherEvenThoughThisIsABadWayToDoIt, clock, cpu]
      simpleConfig = defaultSimpleTaffyConfig 
                        { startWidgets  = startW
                          , endWidgets    = endW
                          , barHeight =  20
                          , barPosition   = Top
                          , widgetSpacing = 0
                        }
  dyreTaffybar $ toTaffyConfig simpleConfig



barSize :: Resolution -> Int
barSize HD  = 25
barSize UHD = 55