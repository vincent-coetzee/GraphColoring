import Cocoa

var str = "Hello, playground"

public class Graph
    {
    public class Node:Hashable
        {
        public static func ==(lhs:Node,rhs:Node) -> Bool
            {
            return(lhs.id == rhs.id)
            }
            
        public var id:String = ""
        public var edges:Array<Edge> = []
        public var color:Color = .none
        
        init(id:String)
            {
            self.id = id
            }
            
        public func hash(into hasher: inout Hasher)
            {
            hasher.combine(self.id)
            }
            
        func edgesEqualTo(edge:Edge) -> Array<Edge>
            {
            return(self.edges.filter{$0 == edge})
            }
            
        func addEdge(_ edge:Edge)
            {
            self.edges.append(edge)
            }
        }
        
    public class Edge:Hashable,Equatable
        {
        public static func ==(lhs:Edge,rhs:Edge) -> Bool
            {
            return(lhs.from.id == rhs.from.id && lhs.to.id == rhs.to.id)
            }
            
        public var from:Node
        public var to:Node

        init(from:Node,to:Node)
            {
            self.from = from
            self.to = to
            }
            
        public func hash(into hasher: inout Hasher)
            {
            hasher.combine(from.id)
            hasher.combine(to.id)
            }
        }
        
    public enum ColoringError:Error
        {
        case notEnoughColors
        }
        
    public enum Color:Int,CaseIterable,Equatable
        {
        case none = 0
        case red = 1
        case orange = 2
        case yellow = 3
        case green = 4
        case blue = 5
        case indigo = 6
        case violet = 7
        
        var name:String
            {
            return("\(self)")
            }
        }
        
    var nodes:[String:Node] = [:]
    var linearNodes:[Node] = []
    
    func nodesAdjacent(to node:Node) -> Array<Node>
        {
        var nodes = node.edges.map{$0.to}
        for aNode in self.nodes.values
            {
            let otherNodes = aNode.edges.filter{$0.to == node}.map{$0.from}
            nodes.append(contentsOf: otherNodes)
            }
        return(nodes)
        }
        
    func nodesOrderedById() -> Array<Node>
        {
        let list = self.nodes.values.sorted{$0.id < $1.id}
        return(Array<Node>(list))
        }
            
    func initGraph()
        {
        self.addEdge(from:"A",to:"C")
        self.addEdge(from:"A",to:"B")
        self.addEdge(from:"A",to:"E")
        self.addEdge(from:"C",to:"E")
        self.addEdge(from:"C",to:"D")
        self.addEdge(from:"C",to:"B")
        self.addEdge(from:"B",to:"D")
        self.addEdge(from:"B",to:"F")
        self.addEdge(from:"D",to:"F")
        self.addEdge(from:"E",to:"F")
        }
        
        
    func newOrExistingNodeWithId(_ id:String) -> Node
        {
        if let node = self.nodes[id]
            {
            return(node)
            }
        let node = Node(id:id)
        self.nodes[id] = node
        return(node)
        }
        
    func addEdge(from:String,to:String)
        {
        let fromNode = self.newOrExistingNodeWithId(from)
        let toNode = self.newOrExistingNodeWithId(to)
        let edge = Edge(from:fromNode,to:toNode)
        guard fromNode.edgesEqualTo(edge:edge).isEmpty else
            {
            return
            }
        fromNode.addEdge(edge)
        }
    //
    // This is a recursive algorithm
    //
    func resursivelyColorGraph() throws
        {
        self.linearNodes = self.nodesOrderedById()
        self.linearNodes[0].color = Color.red
        try self.colorGraph(vertexCount:1)
        }
        
    func colorGraph(vertexCount:Int) throws -> Bool
        {
        if vertexCount >= self.linearNodes.count
            {
            print("\(vertexCount) done finished recursing")
            return(false)
            }
        let vertex = self.linearNodes[vertexCount]
        var colorSet = Set<Color>(Color.allCases)
        colorSet.remove(Color.none)
        print("About to loop over vertexcount to check colors")
        print("vertexCount - 1 = \(vertexCount - 1)")
        for uIndex in 1..<vertexCount
            {
            let uNode = self.linearNodes[uIndex]
            let nodes = self.nodesAdjacent(to: vertex)
            if nodes.contains(uNode)
                {
                colorSet.remove(uNode.color)
                }
            }
        for color in colorSet
            {
            vertex.color = color
            if try !self.colorGraph(vertexCount: vertexCount + 1)
                {
                return(false)
                }
            }
        return(false)
        }
        
    func sequentiallyColor() throws
        {
        // order nodes into some arbitary but staple sequence
        self.linearNodes = self.nodesOrderedById()
        // mark all nodes as uncolored
        for node in self.linearNodes
            {
            node.color = .none
            }
        self.linearNodes[0].color = .red
        for index in stride(from: self.linearNodes.count-1, to: 0, by:-1)
            {
            let vertex = self.linearNodes[index]
            print("Vertex \(vertex.id)")
            let adjacents = self.nodesAdjacent(to: vertex)
            print("Adjacents to vertex=\(vertex.id) are ",terminator:"")
            for adjacent in adjacents
                {
                print("\(adjacent.id) ",terminator:"")
                }
            var usedColors = Set<Color>()
            for adjacent in adjacents
                {
                usedColors.insert(adjacent.color)
                }
            usedColors.remove(.none)
            let names = usedColors.map{$0.name}
            print()
            print("Used colors for vi(\(vertex.id)) are \(names)")
            var someColors = Array<Color>(Color.allCases)
            someColors.remove(at:0)
            for usedColor in usedColors
                {
                someColors.removeAll(where: {$0 == usedColor})
                }
            let color = someColors.first!
            print("Setting vertex color to \(color)")
            vertex.color = color
            }
        }
    }

    
func main()
    {
    let graph = Graph()
    graph.initGraph()
    do
        {
        try graph.sequentiallyColor()
        }
    catch let error
        {
        print("Error is \(error)")
        }
    for node in graph.nodesOrderedById()
        {
        print("NODE[\(node.id)] color is \(node.color))")
        }
    }
    
main()




