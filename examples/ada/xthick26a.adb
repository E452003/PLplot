-- $Id$

-- Multi-lingual version of the first page of example 4.

-- Copyright (C) 2008 Jerry Bauck

-- This file is part of PLplot.

-- Thanks to the following for providing translated strings for this example:
-- Valery Pipin (Russian)  

-- PLplot is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Library Public License as published
-- by the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- PLplot is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Library General Public License for more details.

-- You should have received a copy of the GNU Library General Public License
-- along with PLplot; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

-- This example designed just for devices (e.g., psttfc and the
-- cairo-related devices) that use the pango and fontconfig libraries. The
-- best choice of glyph is selected by fontconfig and automatically rendered
-- by pango in way that is sensitive to complex text layout (CTL) language
-- issues for each unicode character in this example. Of course, you must
-- have the appropriate TrueType fonts installed to have access to all the
-- required glyphs.

-- Translation instructions: The strings to be translated are given by
-- x_label, y_label, alty_label, title_label, and line_label below.-- The 
-- encoding used must be UTF-8.

-- The following strings to be translated involve some scientific/mathematical 
-- jargon which is now discussed further to help translators.

-- (1) dB is a decibel unit, see http://en.wikipedia.org/wiki/Decibel .
-- (2) degrees is an angular measure, see 
--     http://en.wikipedia.org/wiki/Degree_(angle) .
-- (3) low-pass filter is one that transmits (passes) low frequencies.
-- (4) pole is in the mathematical sense, see
--     http://en.wikipedia.org/wiki/Pole_(complex_analysis) .-- "Single Pole"
--     means a particular mathematical transformation of the filter function has
--     a single pole, see
--     http://ccrma.stanford.edu/~jos/filters/Pole_Zero_Analysis_I.html .-- 
--     Furthermore, a single-pole filter must have an inverse square decline 
--     (or -20 db/decade). Since the filter plotted here does have that 
--     characteristic, it must by definition be a single-pole filter, see also
--     http://www-k.ext.ti.com/SRVS/Data/ti/KnowledgeBases/analog/document/faqs/1p.htm
-- (5) decade represents a factor of 10, see
--     http://en.wikipedia.org/wiki/Decade_(log_scale) .

with
    Ada.Numerics,
    Ada.Numerics.Long_Elementary_Functions,
    PLplot_Auxiliary,
    PLplot;
use
    Ada.Numerics,
    Ada.Numerics.Long_Elementary_Functions,
    PLplot_Auxiliary,
    PLplot;



procedure xthick26a is

    function x_label(which : Integer) return String is
    begin
        if which = 0 then return "Frequency"; end if;
        if which = 1 then return "Частота"; end if;
        return "oops";
    end x_label;


    function y_label(which : Integer) return String is
    begin
        if which = 0 then return "Amplitude (dB)"; end if;
        if which = 1 then return "Амплитуда (dB)"; end if;
        return "oops";
    end y_label;


    function alty_label(which : Integer) return String is
    begin
        if which = 0 then return "Phase shift (degrees)"; end if;
        if which = 1 then return "Фазовый сдвиг (градусы)"; end if;
        return "oops";
    end alty_label;


    function title_label(which : Integer) return String is
    begin
        if which = 0 then return "Single Pole Low-Pass Filter"; end if;
        if which = 1 then return "Однополюсный Низко-Частотный Фильтр"; end if;
        return "oops";
    end title_label;


    function line_label(which : Integer) return String is
    begin
        if which = 0 then return "-20 dB/decade"; end if;
        if which = 1 then return "-20 dB/десяток"; end if;
        return "oops";
    end line_label;


    procedure plot1
       (x_label, y_label, alty_label, title_label, line_label : String)
    is
        freql, ampl, phase : Real_Vector(0 .. 100);
        f0, freq : Long_Float;
    begin
        Advance_To_Subpage(Next_Subpage);
        f0 := 1.0;
        for i in freql'range loop
            freql(i) := -2.0 + Long_Float(i) / 20.0;
            freq := 10.0 ** freql(i);
            ampl(i) := 20.0 * log(1.0 / sqrt(1.0 + (freq / f0) ** 2.0), 10.0);
            phase(i) := -(180.0 / pi) * arctan(freq / f0);
        end loop;

        Set_Viewport_Normalized(0.15, 0.85, 0.1, 0.9);
        Set_Viewport_World(-2.0, 3.0, -80.0, 0.0);
        
        -- Try different axis and labelling styles.
        Set_Pen_Color(Red);
        
        Box_Around_Viewport("bclnst", 0.0, 0, "bnstv", 0.0, 0);

        -- Plot ampl vs freq
        Set_Pen_Color(Yellow);
        Draw_Curve(freql, ampl);
        Set_Pen_Color(Red);
        Write_Text_World(1.6, -30.0, 1.0, -20.0, 0.5, line_label);

        -- Put labels on
        Set_Pen_Color(Red);
        Write_Text_Viewport("b", 3.2, 0.5, 0.5, x_label);
        Write_Text_Viewport("t", 2.0, 0.5, 0.5, title_label);
        Set_Pen_Color(Yellow);
        Write_Text_Viewport("l", 5.0, 0.5, 0.5, y_label);

        -- For the gridless case, put phase vs freq on same plot
        Set_Pen_Color(Red);
        Set_Viewport_World(-2.0, 3.0, -100.0, 0.0);
        Box_Around_Viewport("", 0.0, 0, "cmstv", 30.0, 3);
        Set_Pen_Color(Green);
        Draw_Curve(freql, phase);
        Set_Pen_Color(Green);
        Write_Text_Viewport("r", 5.0, 0.5, 0.5, alty_label);
    end plot1;

begin
    -- Parse and process command line arguments */
    Parse_Command_Line_Arguments(Parse_Full);

    -- Initialize plplot
    Initialize_PLplot;
    Set_Font_Style(Roman_Font);

    -- Make log plots using two different styles.
    for i in 0 .. 1 loop
        plot1(x_label(i), y_label(i), alty_label(i), title_label(i), line_label(i));
    end loop;
    
    End_PLplot;
end xthick26a;