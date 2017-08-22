/+ ------------------------------------------------------------ +
 + Author : aoitofu <aoitofu@dr.com>                            +
 + This is part of CAFE ( https://github.com/aoitofu/CAFE ).    +
 + ------------------------------------------------------------ +
 + Please see /LICENSE.                                         +
 + ------------------------------------------------------------ +/
module cafe.project.ComponentList;
import cafe.json,
       cafe.project.Component;
import std.algorithm,
       std.conv,
       std.exception,
       std.json;

debug = 0;

/+ コンポーネントのID型 +/
alias ComponentID = string;

/+ コンポーネントのリスト +/
class ComponentList
{
    enum RootId = "ROOT";
    private:
        Component[ComponentID] comps;

    public:
        /+ 編集情報 +/
        Component selecting = null;

        @property components () { return comps; }

        this ( ComponentList src )
        {
            foreach ( key,val; src.components )
                comps[key] = new Component(val);
        }

        this ()
        {
            comps[RootId] = new Component;
        }

        this ( JSONValue j )
        {
            foreach ( string key,val; j )
                comps[key] = new Component( val );
        }

        /+ ルートコンポーネントを返す +/
        @property root ()
        {
            return this[RootId];
        }

        /+ コンポーネントの削除(参照から) +/
        void del ( Component c )
        {
            if ( c is root ) return;
            comps.remove( components.keys[
                    components.values.countUntil!"a is b"( c )] );
        }

        /+ コンポーネントの削除(IDから) +/
        void del ( ComponentID i )
        {
            if ( i == "ROOT" ) return;
            enforce( i in components, "The component was not found." );
            comps.remove( i );
        }

        /+ コンポーネントのリネーム +/
        void rename ( ComponentID from, ComponentID to )
        {
            if ( from == RootId || to == RootId ) return;
            this[to] = this[from];
            del( from );
        }

        /+ this[i] : コンポーネントの参照 +/
        auto opIndex ( ComponentID i )
        {
            return components[i];
        }

        /+ this[i] = c : コンポーネントの追加 +/
        auto opIndexAssign ( Component c, ComponentID i )
        {
            enforce( i !in components, "Component name conflict." );
            comps[i] = c;
            return this;
        }

        /+ JSON出力 +/
        @property json ()
        {
            JSONValue j;
            foreach ( key,val; components )
                j[key] = JSONValue(val.json);
            return j;
        }

        debug (1) unittest {
            auto hoge = new ComponentList;
            auto hoge2 = new ComponentList( hoge.json );
            assert( hoge.json.to!string == hoge2.json.to!string );
        }
}