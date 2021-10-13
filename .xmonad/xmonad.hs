{-# LANGUAGE AllowAmbiguousTypes, DeriveDataTypeable, TypeSynonymInstances, MultiParamTypeClasses #-}
---------------------------------------------------------------------------
--                                                                       --
--     _|      _|  _|      _|                                      _|    --
--      _|  _|    _|_|  _|_|    _|_|    _|_|_|      _|_|_|    _|_|_|    --
--         _|      _|  _|  _|  _|    _|  _|    _|  _|    _|  _|    _|    --
--       _|  _|    _|      _|  _|    _|  _|    _|  _|    _|  _|    _|    --
--     _|      _|  _|      _|    _|_|    _|    _|    _|_|_|    _|_|_|    --
--                                                                       --
---------------------------------------------------------------------------
-- Ethan Schoonover <es@ethanschoonover.com> @ethanschoonover            --
-- https://github.com/altercation                                        --
---------------------------------------------------------------------------
-- current as of XMonad 0.12


------------------------------------------------------------------------}}}
-- Modules                                                              {{{
---------------------------------------------------------------------------
import Control.Monad (liftM, liftM2, join)  -- myManageHookShift
import Data.List
import qualified Data.Map as M
import Data.Monoid
import System.Exit
import System.IO                            -- for xmonbar
import System.Posix.Process(executeFile)

import XMonad hiding ( (|||) )              -- ||| from X.L.LayoutCombinators
import qualified XMonad.StackSet as W       -- myManageHookShift

import XMonad.Actions.Commands
import XMonad.Actions.ConditionalKeys       -- bindings per workspace or layout
import qualified XMonad.Actions.ConstrainedResize as Sqr
import XMonad.Actions.CopyWindow            -- like cylons, except x windows
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicProjects
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.FloatSnap
import XMonad.Actions.MessageFeedback       -- pseudo conditional key bindings
import XMonad.Actions.Navigation2D
import XMonad.Actions.Promote               -- promote window to master
import XMonad.Actions.SinkAll
import XMonad.Actions.SpawnOn
--import XMonad.Actions.Volume
import XMonad.Actions.WindowGo
import XMonad.Actions.WithAll               -- action all the things

import XMonad.Hooks.DynamicProperty         -- 0.12 broken; works with github version
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks             -- avoid xmobar
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.Accordion
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.BorderResize
import XMonad.Layout.Column
import XMonad.Layout.Combo
import XMonad.Layout.ComboP
import XMonad.Layout.DecorationMadness      -- testing alternative accordion styles
import XMonad.Layout.Dishes
import XMonad.Layout.DragPane
import XMonad.Layout.Drawer
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.Hidden
import XMonad.Layout.LayoutBuilder
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LayoutScreens
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.OneBig
import XMonad.Layout.PerScreen              -- Check screen width & adjust layouts
import XMonad.Layout.PerWorkspace           -- Configure layouts on a per-workspace
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile          -- Resizable Horizontal border
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing                -- this makes smart space around windows
import XMonad.Layout.StackTile
import XMonad.Layout.SubLayouts             -- Layouts inside windows. Excellent.
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts          -- Full window at any time
import XMonad.Layout.TrackFloating
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation

import XMonad.Prompt                        -- to get my old key bindings working
import XMonad.Prompt.ConfirmPrompt          -- don't just hard quit

import XMonad.Util.Cursor
import XMonad.Util.EZConfig                 -- removeKeys, additionalKeys
import XMonad.Util.Loggers
import XMonad.Util.NamedActions
import XMonad.Util.NamedWindows
import XMonad.Util.Paste as P               -- testing
import XMonad.Util.Run                      -- for spawnPipe and hPutStrLn
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare         -- custom WS functions filtering NSP
import XMonad.Util.XSelection


import XMonad.Layout.Tabbed
import XMonad.Layout.Maximize
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders


------------------------------------------------------------------------}}}
-- Main                                                                 {{{
---------------------------------------------------------------------------

main = do

    xmproc <- spawnPipe myStatusBar

    xmonad 
        $ dynamicProjects projects
        $ withNavigation2DConfig myNav2DConf
        $ withUrgencyHook NoUrgencyHook
        $ withUrgencyHook LibNotifyUrgencyHook
        $ ewmh
        $ addDescrKeys' ((myModMask, xK_F1), showKeybindings) myKeys
        $ myConfig xmproc

myConfig p = def
        { borderWidth        = border
        , clickJustFocuses   = myClickJustFocuses
        , focusFollowsMouse  = myFocusFollowsMouse
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , manageHook         = myManageHook
        , handleEventHook    = myHandleEventHook
        , layoutHook         = myLayoutHook
        , modMask            = myModMask
        , startupHook        = myStartupHook
        , terminal           = myTerminal
        , workspaces         = myWorkspaces
        }


------------------------------------------------------------------------}}}
-- Workspaces                                                           {{{
---------------------------------------------------------------------------
    

wsHOME  = "HOME"
wsWRK0  = "SYS"
wsWRK1  = "GO"
wsWRK2  = "C"
wsFLT   = "FLOAT"

-- myWorkspaces = map show [1..9]
myWorkspaces = [wsHOME, wsWRK0, wsWRK1, wsWRK2, wsFLT]

projects :: [Project]
projects =

    [ Project   { projectName       = wsHOME
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsHOME myLauncher

                }

    , Project   { projectName       = wsWRK0
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsWRK0 myTerminal
                                                spawnOn wsWRK0 myTerminal
                                                spawnOn wsWRK0 myTerminal
                }

    , Project   { projectName       = wsWRK1
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsWRK1 myTerminal
                }
   
    , Project   { projectName       = wsWRK2
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsWRK2 myTerminal
                }
    
    , Project   { projectName       = wsFLT
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsFLT myAltBrowser
                }


    ]

------------------------------------------------------------------------}}}
-- Applications                                                         {{{
---------------------------------------------------------------------------


myTerminal          = "alacritty"
myBrowser           = "browser" 
myLauncher          = "rofi -matching fuzzy -modi combi -show combi -combi-modi run,drun"
myStatusBar         = ""
myAltBrowser        = ""


------------------------------------------------------------------------}}}
-- Theme                                                                {{{
---------------------------------------------------------------------------

myFocusFollowsMouse  = True
myClickJustFocuses   = True

base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green       = "#859900"

-- sizes
gap         = 10
topbar      = 10
border      = 0
prompt      = 20
status      = 20

myNormalBorderColor     = "#000000"
myFocusedBorderColor    = active

active      = cyan
activeWarn  = red
inactive    = base00
focusColor  = cyan
unfocusColor = base00

myFont      = "-*-terminus-medium-*-*-*-*-160-*-*-*-*-*-*"
myBigFont   = "-*-terminus-medium-*-*-*-*-240-*-*-*-*-*-*"
myWideFont  = "xft:Eurostar Black Extended:"
            ++ "style=Regular:pixelsize=180:hinting=true"

-- this is a "fake title" used as a highlight bar in lieu of full borders
-- (I find this a cleaner and less visually intrusive solution)
topBarTheme = def
    { fontName              = myFont
    , inactiveBorderColor   = inactive
    , inactiveColor         = inactive
    , inactiveTextColor     = inactive
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = active
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = topbar
    }

myTabTheme = def
    { fontName              = myFont
    , activeColor           = active
    , inactiveColor         = base02
    , activeBorderColor     = active
    , inactiveBorderColor   = base02
    , activeTextColor       = base03
    , inactiveTextColor     = base00
    }

myPromptTheme = def
    { font                  = myFont
    , bgColor               = base03
    , fgColor               = active
    , fgHLight              = base03
    , bgHLight              = active
    , borderColor           = base03
    , promptBorderWidth     = 0
    , height                = prompt
    , position              = Top
    }

warmPromptTheme = myPromptTheme
    { bgColor               = yellow
    , fgColor               = base03
    , position              = Top
    }

hotPromptTheme = myPromptTheme
    { bgColor               = red
    , fgColor               = base3
    , position              = Top
    }

myShowWNameTheme = def
    { swn_font              = myWideFont
    , swn_fade              = 0.5
    , swn_bgcolor           = "#000000"
    , swn_color             = "#FFFFFF"
    }

------------------------------------------------------------------------}}}
-- Layouts                                                              {{{
--
---------------------------------------------------------------------------

-- Tell X.A.Navigation2D about specific layouts and how to handle them

myNav2DConf = def
    { defaultTiledNavigation    = centerNavigation
    , floatNavigation           = centerNavigation
    , screenNavigation          = lineNavigation
    , layoutNavigation          = [("Full",          centerNavigation)
    -- line/center same results   ,("Simple Tabs", lineNavigation)
    --                            ,("Simple Tabs", centerNavigation)
                                  ]
    , unmappedWindowRect        = [("Full", singleWindowRect)
    -- works but breaks tab deco  ,("Simple Tabs", singleWindowRect)
    -- doesn't work but deco ok   ,("Simple Tabs", fullScreenRect)
                                  ]
    }


data FULLBAR = FULLBAR deriving (Read, Show, Eq, Typeable)
instance Transformer FULLBAR Window where
    transform FULLBAR x k = k barFull (\_ -> x)

-- tabBarFull = avoidStruts $ noFrillsDeco shrinkText topBarTheme $ addTabs shrinkText myTabTheme $ Simplest
barFull = avoidStruts $ Simplest

-- cf http://xmonad.org/xmonad-docs/xmonad-contrib/src/XMonad-Config-Droundy.html

myLayoutHook = showWorkspaceName
             $ onWorkspace wsFLT floatWorkspace
             $ fullscreenFloat -- fixes floating windows going full screen, while retaining "bounded" fullscreen
             $ fullScreenToggle
             $ mirrorToggle
             $ reflectToggle
             $ bsp ||| simpleTall  -- triple glyph means concatinating both results

  where

    floatWorkspace      = simplestFloat
    fullScreenToggle    = mkToggle (single FULL)
    mirrorToggle        = mkToggle (single MIRROR)
    reflectToggle       = mkToggle (single REFLECTX)
    smallMonResWidth    = 1920
    showWorkspaceName   = showWName' myShowWNameTheme

    named n             = renamed [(XMonad.Layout.Renamed.Replace n)]
    trimNamed w n       = renamed [(XMonad.Layout.Renamed.CutWordsLeft w),
                                   (XMonad.Layout.Renamed.PrependWords n)]
    suffixed n          = renamed [(XMonad.Layout.Renamed.AppendWords n)]
    trimSuffixed w n    = renamed [(XMonad.Layout.Renamed.CutWordsRight w),
                                   (XMonad.Layout.Renamed.AppendWords n)]

    addTopBar           = noFrillsDeco shrinkText topBarTheme

    mySpacing           = spacingRaw True
                                     (Border 0 0 0 0)
                                     True
                                     (Border 5 5 5 5)
                                     True
    sGap                = quot gap 2
    myGaps              = gaps [(U, gap),(D, gap),(L, gap),(R, gap)]
    mySmallGaps         = gaps [(U, sGap),(D, sGap),(L, sGap),(R, sGap)]
    myBigGaps           = gaps [(U, gap*2),(D, gap*2),(L, gap*2),(R, gap*2)]

    --------------------------------------------------------------------------
    -- Tabs Layout                                                          --
    --------------------------------------------------------------------------

    threeCol = named "Unflexed"
         $ avoidStruts
         $ addTopBar
         $ myGaps
         $ mySpacing
         $ ThreeColMid 1 (1/10) (1/2)

    tabs = named "Tabs"
         $ avoidStruts
         $ addTopBar
         $ addTabs shrinkText myTabTheme
         $ Simplest

    -----------------------------------------------------------------------
    -- Flexi SubLayouts                                                  --
    -----------------------------------------------------------------------
    --
    -- In many ways the best solution. Acts like ThreeColumns, Tall, BSP,
    -- or any other container layout style. Can use this layout just as you
    -- would those without tabs at all, or you can easily merge any windows
    -- into a tabbed group.
    --
    -- Diagrams:
    --
    -- (examples only... this is a very flexible layout and as such the
    -- layout style and arrangement isn't limited as much as the other
    -- attempts below)
    --
    -- Ultrawide:
    -- --------------------------------------------
    -- |          |                    |          |
    -- |          |                    |   Tabs   |
    -- |          |                    |          |
    -- |----------|       Master       |----------|
    -- |          |                    |          |
    -- |   Tabs   |                    |          |
    -- |          |                    |          |
    -- --------------------------------------------
    --
    -- Standard:
    -- ---------------------------------
    -- |                    |          |
    -- |                    |          |
    -- |                    |          |
    -- |       Master       |----------|
    -- |                    |          |
    -- |                    |   Tabs   |
    -- |                    |          |
    -- ---------------------------------
    --
    --
    -- Advantages
    --
    --   * tab group is movable as a unit and acts like any other window
    --
    --   * this is the "cleanest" of the dynamic layouts I've worked with
    --     and leaves no "pixel dust" on the screen when switching to a WS
    --     on a different monitor
    --
    --   * navigation and window/group movement is trivial with
    --     X.A.Navigation2D
    --
    --   * master window remains master when switching screens (unlike
    --     the "X.L.Master" based solution below)
    --
    --   * unlike some of the other solutions, it is trivial to change
    --     the exterior layout format and so I could potentially add in
    --     some layout change to BSP or other layout that I want to test
    --     while still retaining the tab functionality
    --
    -- Disadvantages
    --
    --   * layout starts without any tabs (could be considered a feature
    --     since in that case the layout performs exactly as the parent/
    --     container layout does)
    --
    --   * To move a window into or out of the tabbed group requires
    --     special key bindings unique to X.L.SubLayouts
    --
    --  Understanding XMonad.Layouts.SubLayouts
    --
    --  It took me a while to grok this.
    --
    --  the subLayout hook is used with the following format:
    --
    --    subLayout advanceInnerLayouts innerLayout outerLayout
    --
    --  It works like this: subLayout modifies an entire other layout (or
    --  layouts), enabling you to turn what would be a normal window into
    --  a little group of windows managed by an entirely different layout.
    --
    --  In my case, I'm using layouts like "Three Column" and "Tall" as the
    --  nominal "container" layout (what SubLayouts calls the "outerLayout").
    --
    --  The "inner layout" in my case is just "Simplest". I'm also adding tabs
    --  which are only applied to my sublayouts. Not sure how that works
    --  but it's apparent from the X.L.SubLayouts documentation that this is
    --  the intended use/behavior. Essential X.L.SubLayouts is hijacking these
    --  added tabs and applying them just to the Simplest layout, and then that
    --  in turn is stuck inside the rectangle that would normally hold a window
    --  in my normal layouts.
    --
    --  One of the confusing things for me at first was that the layout doesn't
    --  start with any subLayouts. So it appears to just be a normal layout.
    --  You have to "merge all" to suck everything up into a Simplest tabbed
    --  group and then you can add other windows normally and you'll
    --  have a sublayout with tabs.
    --
    --  Note: subLayouts has some other features. For example, you can give it
    --  a list of layouts to work through and it will advance through them in
    --  series (or possibly in an order your provide) and will apply different
    --  layouts to different subLayout groups. Each time you add a new window
    --  to your layout, it acquires the sublayout, even if you don't know it.
    --
    --  In my case, my list is one long and is just the first window I add.
    --
    --  Ex. The second group is Tall, the third is Circle, all others are
    --  tabbed with:
    --
    --  myLayout = addTabs shrinkText def
    --           $ subLayout [0,1,2] (Simplest ||| Tall 1 0.2 0.5 ||| Circle)
    --                    $ Tall 1 0.2 0.5 ||| Full
   
    -- this is a flexible sublayout layout that has only one container
    -- layout style (depending on screen)
    --     flexiSub = named "Flexi SubLayouts"
    --               $ avoidStruts
    --               $ windowNavigation
    --               $ addTopBar
    --               $ myGaps
    --               $ addTabs shrinkText myTabTheme
    --               $ mySpacing
    --               $ subLayout [] Simplest
    --               $ ifWider smallMonResWidth wideLayout standardLayout
    --               where
    --                   wideLayout = ThreeColMid 1 (1/100) (1/2)
    --                   standardLayout = ResizableTall 1 (1/50) (2/3) []

    -- retained during development: safe to remove later

    flex = trimNamed 5 "Flex"
              $ avoidStruts
              -- don't forget: even though we are using X.A.Navigation2D
              -- we need windowNavigation for merging to sublayouts
              $ windowNavigation
              $ addTopBar
              $ addTabs shrinkText myTabTheme
              -- $ subLayout [] (Simplest ||| (mySpacing $ Accordion))
              $ subLayout [] (Simplest ||| Accordion)
              $ ifWider smallMonResWidth wideLayouts standardLayouts
              where
                  wideLayouts = myGaps $ mySpacing
                      $ (suffixed "Wide 3Col" $ ThreeColMid 1 (1/20) (1/2))
                    ||| (trimSuffixed 1 "Wide BSP" $ hiddenWindows emptyBSP)
                  --  ||| fullTabs
                  standardLayouts = myGaps $ mySpacing
                      $ (suffixed "Std 2/3" $ ResizableTall 1 (1/20) (2/3) [])
                    ||| (suffixed "Std 1/2" $ ResizableTall 1 (1/20) (1/2) [])

                  --  ||| fullTabs
                  --fullTabs = suffixed "Tabs Full" $ Simplest
                  --
                  -- NOTE: removed this from the two (wide/std) sublayout
                  -- sequences. if inside the ifWider, the ||| combinator
                  -- from X.L.LayoutCombinators can't jump to it directly (
                  -- or I'm doing something wrong, either way, it's simpler
                  -- to solve it by just using a tabbed layout in the main
                  -- layoutHook). The disadvantage is that I lose the "per
                  -- screen" memory of which layout was where if using the
                  -- tabbed layout (if using the the ifWider construct as
                  -- I am currently, it seems to work fine)
                  --
                  -- Using "Full" here (instead of Simplest) will retain the
                  -- tabbed sublayout structure and allow paging through each
                  -- group/window in full screen mode. However my preference
                  -- is to just see all the windows as tabs immediately.  
                  -- Using "Simplest" here will do this: display all windows
                  -- as tabs across the top, no "paging" required. However
                  -- this is misleading as the sublayouts are of course still
                  -- there and you will have to use the nornmal W.focusUp/Down
                  -- to successfully flip through them. Despite this
                  -- limitation I prefer this to the results with "Full".


    -----------------------------------------------------------------------
    -- Simple Flexi                                                      --
    -----------------------------------------------------------------------
    --
    -- Simple dynamically resizing layout as with the other variations in
    -- this config. This layout has not tabs in it and simply uses
    -- Resizable Tall and Three Column layouts.

    simpleFlexi = named "Simple Flexible"
              $ ifWider smallMonResWidth simpleThree simpleTall

    simpleTall = named "Tall"
              $ addTopBar
              $ avoidStruts
              $ mySpacing
              $ myGaps
              $ ResizableTall 1 (1/300) (2/3) []
              
    simpleThree = named "Three Col"
              $ avoidStruts
              $ addTopBar
              $ mySpacing
              $ myGaps
              $ ThreeColMid 1 (3/100) (1/2)

    -----------------------------------------------------------------------
    -- Other Misc Layouts                                                --
    -----------------------------------------------------------------------
    --
    --


    bsp       = named "BSP"
              $ borderResize (avoidStruts
              $ addTopBar
              $ mySpacing
              $ myGaps
              $ emptyBSP )
              -- $ borderResize (emptyBSP)

    oneBig    = named "1BG"
              $ avoidStruts
              $ addTopBar
              $ mySpacing
              $ myGaps
              $ OneBig (3/4) (3/4)



    -----------------------------------------------------------------------
    -- Tall-Tabbed Dymamic                                               --
    -----------------------------------------------------------------------
    --
    -- Dynamic 3 pane layout with one tabbed panel using X.L.ComboP
    -- advantage is that it can do a nice 3-up on both ultrawide and
    -- standard (laptop in my case) screen sizes, where the layouts
    -- look like this:
    --
    -- Ultrawide:
    -- --------------------------------------------
    -- |          |                    |          |
    -- |          |                    |          |
    -- |          |                    |          |
    -- |----------|       Master       |   Tabs   |
    -- |          |                    |          |
    -- |          |                    |          |
    -- |          |                    |          |
    -- --------------------------------------------
    -- \______________ _______________/\____ _____/
    --                '                     '
    --        this set of panes is      This is a
    --        its' own layout in a      separate
    --        Tall configuration        tab format
    --                                  layout
    --
    -- Standard:
    -- ---------------------------------
    -- |                    |          |
    -- |                    |          |
    -- |                    |          |
    -- |       Master       |   Tabs   |
    -- |                    |          |
    -- |--------------------|          |
    -- |         |          |          |
    -- ---------------------------------
    -- \_________ _________/\____ _____/
    --           '               '
    -- this set of panes is  This is a
    -- its' own layout in a  separate
    -- Tall configuration    tab format
    --                       layout
    --
    -- Advantages to this use of ComboP to created this dynamic
    -- layout include:
    --
    --   * the center Master stays the same when the layout
    --     changes (unlike the X.L.Master based dyn. layout)
    --
    --   * the Master can have a set of panes under it on the
    --     small screen (standard) layout
    --
    --   * on ultrawide the leftmost pane may be divided into
    --     multiple windows
    --
    --   * possible to toss a tabbed window to the "Master" area
    --     without swapping a window back into tabs
    --
    --   * use of ComboP allows redirection windows to either
    --     left or right section
    --
    -- Disadvantages include:
    --
    --   * normal window swaps fail between the two separate
    --     layouts. There must be a special swap-between-layouts
    --     binding (normal window NAVIGATION works, at least using
    --     X.A.Navigation2D).
    --
    --   * switching between screens can leave title bar clutter
    --     that hasn't been cleaned up properly (restarting
    --     XMonad works to clean this up, but that's hacky)
    --
    --   * somewhat greater need to maintain a mental-map of the
    --     layout (you need to have a sense for the windows being
    --     in separate sections of the different layouts)

    smartTallTabbed = named "Smart Tall-Tabbed"
            $ avoidStruts
            $ ifWider smallMonResWidth wideScreen normalScreen
            where
            wideScreen   = combineTwoP (TwoPane 0.03 (3/4))
                           (smartTall)
                           (smartTabbed)
                           (ClassName "Google-chrome-beta")
            normalScreen = combineTwoP (TwoPane 0.03 (2/3))
                           (smartTall)
                           (smartTabbed)
                           (ClassName "Google-chrome-beta")

    smartTall = named "Smart Tall"
            $ addTopBar
        $ mySpacing
            $ myGaps
            $ ifWider smallMonResWidth wideScreen normalScreen
            where
                wideScreen = reflectHoriz $ Tall 1 0.03 (2/3)
                normalScreen = Mirror $ Tall 1 0.03 (4/5)

    smartTabbed = named "Smart Tabbed"
              $ addTopBar
              $ tabbed shrinkText myTabTheme





------------------------------------------------------------------------}}}
-- Bindings                                                             {{{
---------------------------------------------------------------------------

myModMask = mod4Mask -- super (and on my system, hyper) keys

-- Display keyboard mappings using zenity
-- from https://github.com/thomasf/dotfiles-thomasf-xmonad/
--              blob/master/.xmonad/lib/XMonad/Config/A00001.hs
showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
    h <- spawnPipe "zenity --text-info --font=terminus"
    hPutStr h (unlines $ showKm x)
    hClose h
    return ()


--wsKeys = map show $ [1..9] ++ [0]
wsKeys = ["q", "w", "f", "p", "g"]

-- any workspace but scratchpad
notSP = (return $ ("NSP" /=) . W.tag) :: X (WindowSpace -> Bool)
shiftAndView dir = findWorkspace getSortByIndex dir (WSIs notSP) 1
        >>= \t -> (windows . W.shift $ t) >> (windows . W.greedyView $ t)


-- toggle any workspace but scratchpad
myToggle = windows $ W.view =<< W.tag . head . filter 
        ((\x -> x /= "NSP" && x /= "SP") . W.tag) . W.hidden

myKeys conf = let

    subKeys str ks = subtitle str : mkNamedKeymap conf ks
    screenKeys     = ["w","v","z"]
    dirKeys        = ["j","k","h","l"]
    arrowKeys        = ["<D>","<U>","<L>","<R>"]
    dirs           = [ D,  U,  L,  R ]

    --screenAction f        = screenWorkspace >=> flip whenJust (windows . f)

    zipM  m nm ks as f = zipWith (\k d -> (m ++ k, addName nm $ f d)) ks as
    zipM' m nm ks as f b = zipWith (\k d -> (m ++ k, addName nm $ f d b)) ks as

    -- from xmonad.layout.sublayouts
    focusMaster' st = let (f:fs) = W.integrate st
        in W.Stack f [] fs
    swapMaster' (W.Stack f u d) = W.Stack f [] $ reverse u ++ d

    -- try sending one message, fallback if unreceived, then refresh
    tryMsgR x y = sequence_ [(tryMessageWithNoRefreshToCurrent x y), refresh]

    -- warpCursor = warpToWindow (9/10) (9/10)

    -- cf https://github.com/pjones/xmonadrc
    --switch :: ProjectTable -> ProjectName -> X ()
    --switch ps name = case Map.lookup name ps of
    --  Just p              -> switchProject p
    --  Nothing | null name -> return ()

    -- do something with current X selection
    unsafeWithSelection app = join $ io $ liftM unsafeSpawn $ fmap (\x -> app ++ " " ++ x) getSelection

    toggleFloat w = windows (\s -> if M.member w (W.floating s)
                    then W.sink w s
                    else (W.float w (W.RationalRect (1/3) (1/4) (1/2) (4/5)) s))

    in

    -----------------------------------------------------------------------
    -- System / Utilities
    -----------------------------------------------------------------------
    subKeys "System"
    [ ("M-C-q"                  , addName "Rebuild & restart XMonad"        $ spawn "xmonad --recompile && xmonad --restart")
    , ("M-S-q"                  , addName "Quit XMonad"                     $ confirmPrompt hotPromptTheme "Quit XMonad" $ io (exitWith ExitSuccess))
    ] ^++^

    -----------------------------------------------------------------------
    -- Launchers
    -----------------------------------------------------------------------
    subKeys "Launchers"
    [ ("M-<Space>"              , addName "Launcher"                        $ spawn myLauncher)
    , ("M-<Return>"             , addName "Terminal"                        $ spawn myTerminal)
    , ("M-\\"                   , addName "Browser"                         $ spawn myBrowser)
    ] ^++^

    -----------------------------------------------------------------------
    -- Windows
    -----------------------------------------------------------------------

    subKeys "Windows"
    (
    [ ("M-<Backspace>"          , addName "Kill"                            kill1)
    , ("M-S-<Backspace>"        , addName "Kill all"                        $ confirmPrompt hotPromptTheme "kill all" $ killAll)
    , ("M-d"                    , addName "Duplicate w to all ws"           $ toggleCopyToAll)

    , ("M-'"                    , addName "Navigate tabs D"                 $ bindOn LD [("Tabs", windows W.focusDown), ("", onGroup W.focusDown')])
    , ("M-;"                    , addName "Navigate tabs U"                 $ bindOn LD [("Tabs", windows W.focusUp), ("", onGroup W.focusUp')])
    , ("C-'"                    , addName "Swap tab D"                      $ windows W.swapDown)
    , ("C-;"                    , addName "Swap tab U"                      $ windows W.swapUp)

    -- ComboP specific (can remove after demo)
    , ("M-C-S-m"                , addName "Combo swap"                      $ sendMessage $ SwapWindow)
    ]

    ++ zipM' "M-"               "Navigate window"                           dirKeys dirs windowGo True
    -- ++ zipM' "M-S-"               "Move window"                               dirKeys dirs windowSwap True
    -- TODO: following may necessitate use of a "passthrough" binding that can send C- values to focused w
    -- ++ zipM' "C-"             "Move window"                               dirKeys dirs windowSwap True
    ++ zipM  "M-C-"             "Merge w/sublayout"                         dirKeys dirs (sendMessage . pullGroup)
    ++ zipM' "M-"               "Navigate screen"                           arrowKeys dirs screenGo True
    -- ++ zipM' "M-S-"             "Move window to screen"                     arrowKeys dirs windowToScreen True
    ++ zipM' "M-C-"             "Move window to screen"                     arrowKeys dirs windowToScreen True
    ++ zipM' "M-S-"             "Swap workspace to screen"                  arrowKeys dirs screenSwap True

    ) ^++^

    -----------------------------------------------------------------------
    -- Workspaces & Projects
    -----------------------------------------------------------------------

    subKeys "Workspaces & Projects"
    (
    [-- ("M-w"                    , addName "Switch to Project"           $ switchProjectPrompt warmPromptTheme)
     -- , ("M-S-w"                  , addName "Shift to Project"            $ shiftToProjectPrompt warmPromptTheme)
    ("M-a"                    , addName "Toggle last workspace"       $ toggleWS' ["NSP"])
    ]
    ++ zipM "M-"                "View      ws"                          wsKeys [0..] (withNthWorkspace W.greedyView)
    -- ++ zipM "M-S-"              "Move w to ws"                          wsKeys [0..] (withNthWorkspace W.shift)
    -- TODO: following may necessitate use of a "passthrough" binding that can send C- values to focused w
    ++ zipM "M-M1-"                "Move w to ws"                          wsKeys [0..] (withNthWorkspace W.shift)
    -- TODO: make following a submap
    ++ zipM "M-S-C-"            "Copy w to ws"                          wsKeys [0..] (withNthWorkspace copy)
    ) ^++^

    -----------------------------------------------------------------------
    -- Layouts & Sublayouts
    -----------------------------------------------------------------------

    subKeys "Layout Management"

    [ ("M-<Tab>"                , addName "Cycle all layouts"               $ sendMessage NextLayout)
    , ("M-C-<Tab>"              , addName "Cycle sublayout"                 $ toSubl NextLayout)
    , ("M-S-<Tab>"              , addName "Reset layout"                    $ setLayout $ XMonad.layoutHook conf)

    , ("M-y"                    , addName "Float tiled w"                   $ withFocused toggleFloat)
    , ("M-S-y"                  , addName "Tile all floating w"             $ sinkAll)

    , ("M-r"                    , addName "Reflect/Rotate"              $ tryMsgR (Rotate) (XMonad.Layout.MultiToggle.Toggle REFLECTX))
    , ("M-S-r"                  , addName "Force Reflect (even on BSP)" $ sendMessage (XMonad.Layout.MultiToggle.Toggle REFLECTX))

    , ("M-s"                    , addName "Fullscreen"                      $ sequence_ [ (withFocused $ windows . W.sink)
                                                                        , (sendMessage $ XMonad.Layout.MultiToggle.Toggle FULL) ])

    ] ^++^

    -----------------------------------------------------------------------
    -- Reference
    -----------------------------------------------------------------------
    -- recent windows not working
    -- , ("M4-<Tab>",              , addName "Cycle recent windows"        $ (cycleRecentWindows [xK_Super_L] xK_Tab xK_Tab))
    -- either not using these much or (in case of two tab items below), they conflict with other bindings
    -- so I'm just turning off this whole section for now. retaining for refernce after a couple months
    -- of working with my bindings to see if I want them back. TODO REVIEW
    --, ("M-s m"                  , addName "Swap master"                 $ windows W.shiftMaster)
    --, ("M-s p"                  , addName "Swap next"                   $ windows W.swapUp)
    --, ("M-s n"                  , addName "Swap prev"                   $ windows W.swapDown)
    --, ("M-<Tab>"                , addName "Cycle up"                    $ windows W.swapUp)
    --, ("M-S-<Tab>"              , addName "Cycle down"                  $ windows W.swapDown)

    -- sublayout specific (unused)
    -- , ("M4-C-S-m"               , addName "onGroup focusMaster"         $ onGroup focusMaster')
    -- , ("M4-C-S-]"               , addName "toSubl IncMasterN 1"         $ toSubl $ IncMasterN 1)
    -- , ("M4-C-S-["               , addName "toSubl IncMasterN -1"        $ toSubl $ IncMasterN (-1))
    -- , ("M4-C-S-<Return>"        , addName "onGroup swapMaster"          $ onGroup swapMaster')


    -----------------------------------------------------------------------
    -- Resizing
    -----------------------------------------------------------------------

    subKeys "Resize"

    [

    -- following is a hacky hack hack
    --
    -- I want to be able to use the same resize bindings on both BinarySpacePartition and other
    -- less sophisticated layouts. BSP handles resizing in four directions (amazing!) but other
    -- layouts have less refined tastes and we're lucky if they just resize the master on a single
    -- axis.
    --
    -- To this end, I am using X.A.MessageFeedback to test for success on using the BSP resizing
    -- and, if it fails, defaulting to the standard (or the X.L.ResizableTile Mirror variants)
    -- Expand and Shrink commands.
    --
    -- The "sequence_" wrapper is needed because for some reason the windows weren't resizing till
    -- I moved to a different window or refreshed, so I added that here. Shrug.
    
    -- mnemonic: less than / greater than
    --, ("M4-<L>"       , addName "Expand (L on BSP)"     $ sequence_ [(tryMessage_ (ExpandTowards L) (Expand)), refresh])

--      ("C-<L>"                  , addName "Expand (L on BSP)"           $ tryMsgR (ExpandTowards L) (Shrink))
--    , ("C-<R>"                  , addName "Expand (R on BSP)"           $ tryMsgR (ExpandTowards R) (Expand))
--    , ("C-<U>"                  , addName "Expand (U on BSP)"           $ tryMsgR (ExpandTowards U) (MirrorShrink))
--    , ("C-<D>"                  , addName "Expand (D on BSP)"           $ tryMsgR (ExpandTowards D) (MirrorExpand))
--
--    , ("C-S-<L>"                , addName "Shrink (L on BSP)"           $ tryMsgR (ShrinkFrom R) (Shrink))
--    , ("C-S-<R>"                , addName "Shrink (R on BSP)"           $ tryMsgR (ShrinkFrom L) (Expand))
--    , ("C-S-<U>"                , addName "Shrink (U on BSP)"           $ tryMsgR (ShrinkFrom D) (MirrorShrink))
--    , ("C-S-<D>"                , addName "Shrink (D on BSP)"           $ tryMsgR (ShrinkFrom U) (MirrorExpand))

      ("M-M1-h"                    , addName "Expand (L on BSP)"           $ tryMsgR (ExpandTowards L) (Shrink))
    , ("M-M1-l"                    , addName "Expand (R on BSP)"           $ tryMsgR (ExpandTowards R) (Expand))
    , ("M-M1-k"                  , addName "Expand (U on BSP)"           $ tryMsgR (ExpandTowards U) (MirrorShrink))
    , ("M-M1-j"                  , addName "Expand (D on BSP)"           $ tryMsgR (ExpandTowards D) (MirrorExpand))

    , ("M-C-["                  , addName "Shrink (L on BSP)"           $ tryMsgR (ShrinkFrom R) (Shrink))
    , ("M-C-]"                  , addName "Shrink (R on BSP)"           $ tryMsgR (ShrinkFrom L) (Expand))
    , ("M-C-S-["                , addName "Shrink (U on BSP)"           $ tryMsgR (ShrinkFrom D) (MirrorShrink))
    , ("M-C-S-]"                , addName "Shrink (D on BSP)"           $ tryMsgR (ShrinkFrom U) (MirrorExpand))

  --, ("M-r"                    , addName "Mirror (BSP rotate)"         $ tryMsgR (Rotate) (XMonad.Layout.MultiToggle.Toggle MIRROR))
  --, ("M-S-C-m"                , addName "Mirror (always)"             $ sendMessage $ XMonad.Layout.MultiToggle.Toggle MIRROR)
  --, ("M4-r"                   , addName "BSP Rotate"                  $ sendMessage Rotate)

-- TODO: the following are potentially useful but I won't know till I work with BSP further
--    , ("M4-s"                   , addName "BSP Swap"                    $ sendMessage XMonad.Layout.BinarySpacePartition.Swap)
--    , ("M4-p"                   , addName "BSP Focus Parent"            $ sendMessage FocusParent)
--    , ("M4-n"                   , addName "BSP Select Node"             $ sendMessage SelectNode)
    --, ("M4-m"                   , addName "BSP Move Node"               $ sendMessage MoveNode)

    -- sublayout specific (unused)
    --  ("M4-C-S-."               , addName "toSubl Shrink"               $ toSubl Shrink)
    --, ("M4-C-S-,"               , addName "toSubl Expand"               $ toSubl Expand)
    ]
		where
			toggleCopyToAll = wsContainingCopies >>= \ws -> case ws of
							[] -> windows copyToAll
							_ -> killAllOtherCopies

    


------------------------------------------------------------------------}}}
-- Startup                                                              {{{
---------------------------------------------------------------------------

myStartupHook = do

    setDefaultCursor xC_left_ptr

quitXmonad :: X ()
quitXmonad = io (exitWith ExitSuccess)

rebuildXmonad :: X ()
rebuildXmonad = do
    spawn "xmonad --recompile && xmonad --restart"

restartXmonad :: X ()
restartXmonad = do
    spawn "xmonad --restart"


------------------------------------------------------------------------}}}
-- Actions                                                              {{{
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Urgency Hook                                                            
---------------------------------------------------------------------------
-- from https://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        name     <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset

        safeSpawn "notify-send" [show name, "workspace " ++ idx]
-- cf https://github.com/pjones/xmonadrc


---------------------------------------------------------------------------
-- New Window Actions
---------------------------------------------------------------------------

-- https://wiki.haskell.org/Xmonad/General_xmonad.hs_config_tips#ManageHook_examples
-- <+> manageHook defaultConfig

myManageHook :: ManageHook
myManageHook =
        manageSpecific
    <+> manageDocks
    <+> fullscreenManageHook
    <+> manageSpawn
    where
        manageSpecific = composeOne
            [ resource =? "desktop_window" -?> doIgnore
            , resource =? "stalonetray"    -?> doIgnore
            , resource =? "vlc"    -?> doFloat
            , transience
            , isRole =? gtkFile  -?> forceCenterFloat
            , isDialog -?> doCenterFloat
            , isRole =? "pop-up" -?> doCenterFloat
            , isInProperty "_NET_WM_WINDOW_TYPE"
                           "_NET_WM_WINDOW_TYPE_SPLASH" -?> doCenterFloat
            , resource =? "console" -?> tileBelowNoFocus
            , isFullscreen -?> doFullFloat
            , pure True -?> tileBelow ]
        gtkFile = "GtkFileChooserDialog"
        isRole = stringProperty "WM_WINDOW_ROLE"
        -- insert WHERE and focus WHAT
        tileBelow = insertPosition Below Newer
        tileBelowNoFocus = insertPosition Below Older

---------------------------------------------------------------------------
-- X Event Actions
---------------------------------------------------------------------------

-- for reference, the following line is the same as dynamicTitle myDynHook
-- <+> dynamicPropertyChange "WM_NAME" myDynHook

-- I'm not really into full screens without my say so... I often like to
-- fullscreen a window but keep it constrained to a window rect (e.g.
-- for videos, etc. without the UI chrome cluttering things up). I can
-- always do that and then full screen the subsequent window if I want.
-- THUS, to cut a long comment short, no fullscreenEventHook
-- <+> XMonad.Hooks.EwmhDesktops.fullscreenEventHook

myHandleEventHook = docksEventHook
                <+> fadeWindowsEventHook
                <+> handleEventHook def
                <+> XMonad.Layout.Fullscreen.fullscreenEventHook

---------------------------------------------------------------------------
-- Custom hook helpers
---------------------------------------------------------------------------

-- from:
-- https://github.com/pjones/xmonadrc/blob/master/src/XMonad/Local/Action.hs
--
-- Useful when a floating window requests stupid dimensions.  There
-- was a bug in Handbrake that would pop up the file dialog with
-- almost no height due to one of my rotated monitors.

forceCenterFloat :: ManageHook
forceCenterFloat = doFloatDep move
  where
    move :: W.RationalRect -> W.RationalRect
    move _ = W.RationalRect x y w h

    w, h, x, y :: Rational
    w = 1/3
    h = 1/2
    x = (1-w)/2
    y = (1-h)/2



-- vim: ft=haskell:foldmethod=marker:expandtab:ts=4:shiftwidth=4
