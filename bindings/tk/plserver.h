/* $Id$
 * $Log$
 * Revision 1.11  1994/01/15 17:40:04  mjl
 * Changed PLRDev definition to use pointer to PDFstrm instead of file
 * handle.  Added prototypes for new socket i/o functions.
 *
 * Revision 1.10  1993/12/15  08:59:28  mjl
 * Added prototypes for Tcl_AppInit() and set_autopath().
 *
 * Revision 1.9  1993/12/09  21:19:26  mjl
 * Changed prototype for tk_toplevel().
 *
 * Revision 1.8  1993/12/09  20:33:41  mjl
 * Eliminated unneccessary system header file inclusions.
 *
 * Revision 1.7  1993/12/08  06:18:08  mjl
 * Changed to include new plplotX.h header file.
 *
 * Revision 1.6  1993/11/19  07:31:20  mjl
 * Fixed the prototype for tk_toplevel().
 */

/* 
 * plserver.h
 * Maurice LeBrun
 * 6-May-93
 *
 * Declarations for plserver and associated files.  
 */

#include "plplotP.h"
#include "plplotX.h"
#include "plplotio.h"
#include "pdf.h"
#include "plstream.h"

#include <tcl.h>
#include <tk.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

/* This data structure holds all state info for the rendering code */

typedef struct {
    char  *client;			/* Name of client main window */
    PDFstrm *pdfs;			/* PDF stream descriptor */
    FILE  *fifo;			/* FIFO handle (if needed) */
    char  *filetype;			/* Set to "fifo" or "buffer" */
    char  *socket;			/* Socket name (if needed) */
    int   nbytes;			/* data bytes waiting to be read */

    short xmin, xmax, ymin, ymax;	/* Data minima and maxima */
    PLFLT xold, yold;			/* Endpoints of last line plotted */
} PLRDev;

/* External function prototypes. */

/* from tkshell.c */

/* Create top level window */

int
tk_toplevel(Tk_Window *w, Tcl_Interp *interp,
	    char *display, char *basename, char *classname);

/* Run a script */

int
tk_source(Tk_Window w, Tcl_Interp *interp, char *script);

/* performs application-specific initialization */

int
Tcl_AppInit(Tcl_Interp *interp);

/* Sets up auto_path variable */

int
set_auto_path(Tcl_Interp *interp);

/* Tcl command -- wait until the specified condition is satisfied. */

int
Wait_Until(ClientData, Tcl_Interp *, int, char **);

/* from plr.c */

/* Set default state parameters before anyone else has a chance to. */

void
plr_start(PLRDev *plr);

/* Read & process commands until "nbyte_max" bytes have been read. */

int
plr_process(PLRDev *plr);

/* From tcpip.c */

/* C interface to the "dp_packetReceive" command. */

int
pl_PacketReceive(Tcl_Interp *interp, char *fileHandle, int peek,
		 PDFstrm *pdfs);

/* C interface to the "dp_packetSend" command. */

int
pl_PacketSend(Tcl_Interp *interp, char *fileHandle, PDFstrm *pdfs);

/* Tcl command -- return the IP address for the current host.  */

int
Host_ID(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
