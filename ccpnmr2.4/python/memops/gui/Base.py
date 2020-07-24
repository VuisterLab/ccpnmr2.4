
"""
======================COPYRIGHT/LICENSE START==========================

Base.py: <write function here>

Copyright (C) 2008 Wayne Boucher, Rasmus Fogh, Tim Stevens and Wim Vranken (University of Cambridge and EBI/MSD)

=======================================================================

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
 
A copy of this license can be found in ../../../license/LGPL.license
 
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
 
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


======================COPYRIGHT/LICENSE END============================

for further information, please contact :

- CCPN website (http://www.ccpn.ac.uk/)
- PDBe website (http://www.ebi.ac.uk/pdbe/)

=======================================================================

If you are using this software for academic purposes, we suggest
quoting the following references:

===========================REFERENCE START=============================
R. Fogh, J. Ionides, E. Ulrich, W. Boucher, W. Vranken, J.P. Linge, M.
Habeck, W. Rieping, T.N. Bhat, J. Westbrook, K. Henrick, G. Gilliland,
H. Berman, J. Thornton, M. Nilges, J. Markley and E. Laue (2002). The
CCPN project: An interim report on a data model for the NMR community
(Progress report). Nature Struct. Biol. 9, 416-418.

Wim F. Vranken, Wayne Boucher, Tim J. Stevens, Rasmus
H. Fogh, Anne Pajon, Miguel Llinas, Eldon L. Ulrich, John L. Markley, John
Ionides and Ernest D. Laue (2005). The CCPN Data Model for NMR Spectroscopy:
Development of a Software Pipeline. Proteins 59, 687 - 696.

===========================REFERENCE END===============================
"""

# basic additional code that all widgets can use

import Tkinter

from memops.gui.ToolTip import ToolTip

# getPopup returns popup which contains widget
def getPopup(widget):

  popup = widget
  while (not isinstance(popup, Tkinter.Toplevel)) and popup.main:
    popup = popup.main

  return popup

# getRoot returns root of widget hierarchy
def getRoot(widget):

  root = widget
  while root.main:
    root = root.main

  return root

# getWidgetCount returns count of widgets in hierarchy starting at widget (e.g. the root)
def getWidgetCount(widget):

  count = 1
  for child in widget.children.values():
    count += getWidgetCount(child)

  return count

# assumes that some other class which is a widget class is used in parallel

class Base(object):

  objectDoc = toolTip = None # in case constructor not called still want these to exist

  def __init__(self, docKey=None, tipText=None, createToolTip=True):

    from memops.gui.BasePopup import BasePopup

    objectDoc = None
    if isinstance(self, BasePopup):
      if hasattr(self, 'popupDoc'):
        objectDoc = self.popupDoc
    else: # for now allow docKey=None to be valid
      parentDoc = self.getParentDoc()
      if parentDoc:
        objectDoc = parentDoc.get(docKey)

    if objectDoc and not tipText:
      tipText = objectDoc.documentation

    self.docKey = docKey
    self.objectDoc = objectDoc
    self.tipText = tipText

    if tipText and createToolTip:
      self.toolTip = ToolTip(self, text=tipText)

  def getParentDoc(self):

    parentDoc =  None
    widget = self.main
    while widget:
      if hasattr(widget, 'objectDoc') and widget.objectDoc:
        parentDoc =  widget.objectDoc
        break
      if isinstance(widget, Tkinter.Toplevel):
        break
      widget = widget.main

    return parentDoc

  def getPopup(self):

    return getPopup(self)

