package polymod.hscript;

/**
 * Stub for event handling.
 */
class HScriptedEvent {
    public var name:String;
    public var args:Array<Dynamic>;

    public function new(name:String, args:Array<Dynamic>) {
        this.name = name;
        this.args = args;
    }
}
