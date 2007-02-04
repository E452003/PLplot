/* $Id$

   Copyright (C) 2005  Werner Smekal

   This file is part of PLplot.

   PLplot is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Library Public License as published
   by the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   PLplot is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Library General Public License for more details.

   You should have received a copy of the GNU Library General Public License
   along with PLplot; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include "plplotP.h"
#include "wxPLplotstream.h"
#include "wx/image.h"
#include "wx/dcmemory.h"


/*! Constructor of wxPLplotstream class which is inherited from plstream.
 *  Here we set the driver (wxwidgets :), and tell plplot in which dc to
 *  plot to and the size of the canvas. We also check and set several
 *  device style options.
 */
wxPLplotstream::wxPLplotstream( wxDC *dc, int width, int height, long style ) :
                m_dc(dc), m_width(width), m_height(height), m_style(style)
{
  ::plstream();

  sdev( "wxwidgets" );
  spage( 0.0, 0.0, m_width, m_height, 0, 0 );

  // use freetype?
  wxString option=wxString::Format(
    "text=%d,smooth=%d,antialized=%d",
    m_style & wxPLPLOT_FREETYPE ? 1 : 0,
    m_style & wxPLPLOT_SMOOTHTEXT ? 1 : 0,
    m_style & wxPLPLOT_ANTIALIZED ? 1 : 0 );
  SetOpt( "-drvopt", (char*)option.mb_str(*wxConvCurrent) );

  init();
  if( m_style & wxPLPLOT_ANTIALIZED ) {
    m_image = new wxImage( m_width, m_height );
    cmd( PLESC_DEVINIT, (void*)m_image );
  } else
    cmd( PLESC_DEVINIT, (void*)m_dc );
}


/*! This is the overloaded set_stream() function, where we could have some
 *  code processed before every call of a plplot functions, since set_stream()
 *  is called before every plplot function. Not used in the moment.
 */
void wxPLplotstream::set_stream()
{
  plstream::set_stream();
}


/*! Call this method if the size of the dc changed (because of resizing)
 *  to set the new size. You need to call RenewPlot afterwards.
 */
void wxPLplotstream::SetSize( int width, int height )
{
	m_width=width;
	m_height=height;

  if( m_style & wxPLPLOT_ANTIALIZED )
    m_image->Resize( wxSize(m_width, m_height), wxPoint(0, 0) );

  wxSize size( m_width, m_height );
  cmd( PLESC_RESIZE, (void*)&size );
}


/*! Clear the background and replot everything. TODO: actually this should
 *  not be necessary, but bop() is not working as it should?
 */
void wxPLplotstream::RenewPlot()
{
  cmd( PLESC_CLEAR, NULL );
  replot();

  if( m_style & wxPLPLOT_ANTIALIZED ) {
    wxMemoryDC MemoryDC;
    MemoryDC.SelectObject( wxBitmap(m_image, -1) );
    m_dc->Blit( 0, 0, m_width, m_height, &MemoryDC, 0, 0 );
    MemoryDC.SelectObject( wxNullBitmap );
  }
}

