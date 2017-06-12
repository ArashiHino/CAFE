/+ ------------------------------------------------------------ +
 + Author : aoitofu <aoitofu@dr.com>                            +
 + This is part of CAFE ( https://github.com/aoitofu/CAFE ).    +
 + ------------------------------------------------------------ +
 + Please see /LICENSE.                                         +
 + ------------------------------------------------------------ +/
module cafe.gui.controls.BMPViewer;
import cafe.gui.BitmapLight,
       cafe.renderer.graphics.Bitmap;
import dlangui;

/+ BMPを表示するウィジェット +/
class BMPViewer : Widget
{
    private:
        DrawBuf bmp;

    public:
        @property bitmap () { return bmp; }
        @property bitmap ( DrawBuf bmp )
        {
            this.bmp = bmp;
            invalidate;
        }

        this ( string id, DrawBuf bmp = null )
        {
            super( id );
            bitmap = bmp;
        }

        this ( string id, BMP bmp )
        {
            this( id, new BitmapLight( bmp ) );
        }

        override void onDraw ( DrawBuf b )
        {
            if ( !bitmap ) return;
            auto dst_rect = Rect( 0, 0, width, height );
            auto src_rect = Rect( 0, 0, bitmap.width, bitmap.height );
            b.drawRescaled( dst_rect, bitmap, src_rect );
        }
}