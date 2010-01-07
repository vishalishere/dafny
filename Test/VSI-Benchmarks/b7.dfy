// Edited B6 to include GetChar and PutChar 

//This is the Queue from Benchmark 3.

//restriction:we assume streams are finite 
//what else can we specify?


class Queue<T> {
  var contents: seq<T>;
  method Init();
    modifies this;
    ensures |contents| == 0;
  method Enqueue(x: T);
    modifies this;
    ensures contents == old(contents) + [x];
  method Dequeue() returns (x: T);
    requires 0 < |contents|;
    modifies this;
    ensures contents == old(contents)[1..] && x == old(contents)[0];
  function Head(): T
    requires 0 < |contents|;
    reads this;
  { contents[0] }
  function Get(i: int): T
    requires 0 <= i && i < |contents|;
    reads this;
  { contents[i] }
}

class Stream {
  var footprint:set<object>;
  var stream:seq<int>; 
  var isOpen:bool;
  
  function Valid():bool
  reads this, footprint;
  {
	null !in footprint && this in footprint && isOpen
  }
  
  method GetCount() returns (c:int)
  requires Valid();
  ensures 0<=c;
  {
		c:=|stream|;
  }
  
  method Create() //writing
  modifies this;
  ensures Valid() && fresh(footprint -{this});
  ensures stream == [];
  {
		stream := [];
		footprint := {this}; 
		isOpen:= true;
  }
 
  method Open() //reading
  modifies this;
  ensures Valid() && fresh(footprint -{this});
  {
		footprint := {this}; 
		isOpen :=true;
  }
  
  method PutChar(x:int )
  requires Valid();
  modifies footprint;
  ensures Valid() && fresh(footprint - old(footprint));
  ensures stream == old(stream) + [x];
  {
		stream:= stream + [x];
  }
  
  method GetChar()returns(x:int)
  requires Valid() && 0< |stream|;
  modifies footprint;
  ensures Valid() && fresh(footprint - old(footprint));
  ensures x ==old(stream)[0];
  ensures stream == old(stream)[1..]; 
  {
		x := stream[0];
		stream:= stream[1..];
	
  }
 
 method AtEndOfStream() returns(eos:bool)
 requires Valid();
 ensures eos   <==> |stream| ==0; 
 {
	eos:= |stream| ==0; 
 }
  
 method Close() 
 requires Valid();
 modifies footprint;
 {
	isOpen := false;
	
 }
  
}



class Client {


  method Sort(q: Queue<int>) returns (r: Queue<int>, perm:seq<int>);
    requires q != null;
    modifies q;
    ensures r != null && fresh(r);
    ensures |r.contents| == |old(q.contents)|;
    ensures (forall i, j :: 0 <= i && i < j && j < |r.contents| ==>
                r.Get(i) <= r.Get(j));
    //perm is a permutation
   ensures |perm| == |r.contents|; // ==|pperm|
   ensures (forall i: int :: 0 <= i && i < |perm|==> 0 <= perm[i] && perm[i] < |perm| );
   ensures (forall i, j: int :: 0 <= i && i < j && j < |perm| ==> perm[i] != perm[j]); 
   // the final Queue is a permutation of the input Queue
  ensures (forall i: int :: 0 <= i && i < |perm| ==> r.contents[i] == old(q.contents)[perm[i]]);
  
  
	
	method Main()
	{
		var rd:= new Stream;
		call rd.Open();
		
		var q:= new Queue<int>;	
		while (true)
		 invariant rd.Valid() && fresh(rd.footprint) && fresh(q);
		 decreases |rd.stream|;
		{
				call eos := rd.AtEndOfStream();
				if (eos) 
				{
					break;
				}
				
				call ch := rd.GetChar();	
				call q.Enqueue(ch);	
	    }
	    
	    call rd.Close();
	    call q,perm := Sort(q);
	    
	    var wr:= new Stream;
	    call wr.Create();
	    while (0<|q.contents|)
	    invariant wr.Valid() && fresh(wr.footprint) && fresh(q) && q !in wr.footprint;
	    decreases |q.contents|;
		{
				call ch:= q.Dequeue();	
				call wr.PutChar(ch);		
	    }
	    call wr.Close();
	    
	}
	
}
