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
        public var color = Color.none
        
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
        case error = 8
        
        static var first:Color
            {
            return(Color.red)
            }
            
        func nextLowest() -> Color
            {
            let index = min(self.rawValue + 1,Color.error.rawValue)
            return(Color(rawValue:index)!)
            }
         
        static func nextLowestUnusedColor(excluding set:Set<Color>) -> Color
            {
            var index = Color.none.rawValue
            for color in set
                {
                index = max(index,color.rawValue)
                }
            index = min(index + 1,Color.error.rawValue)
            return(Color(rawValue:index)!)
            }
        }
        
    var nodes:[String:Node] = [:]
        
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
            
    func uniqueColorsAdjacent(to node:Node) -> Set<Color>
        {
        var colors = Set<Color>()
        print("Adjacent nodes for \(node.id) are \(self.nodesAdjacent(to:node).map{$0.id})")
        for other in self.nodesAdjacent(to:node)
            {
            colors.insert(other.color)
            }
        var allEdges = Array<Edge>(node.edges)
        for aNode in self.nodesAdjacent(to:node)
            {
            let otherEdges = aNode.edges.filter{$0.from == node || $0.to == node}
            allEdges.append(contentsOf: otherEdges)
            }
        print("Edges for \(node.id) are")
        for edge in allEdges
            {
            print("\tEDGE(\(edge.from.id),\(edge.to.id))")
            }
        return(colors)
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
        
    func colorGraph() throws
        {
        var allNodes = Array(self.nodes.values).sorted{$0.id < $1.id}
        let first = allNodes.first!
        allNodes = allNodes.withoutFirst()
        first.color = Color.first
        print("Coloring node \(first.id) as \(first.color)")
        while !allNodes.isEmpty
            {
            let node = allNodes.first!
            allNodes = allNodes.withoutFirst()
            print("Removing \(node.id) from \(allNodes.map{$0.id})")
            let adjacentColors = self.uniqueColorsAdjacent(to:node)
            print("Adjacent unique colors are for \(node.id) of color \(node.color)")
            for color in adjacentColors
                {
                print("\t\(color)")
                }
            let nextColor = Color.nextLowestUnusedColor(excluding: adjacentColors)
            print("Next lowest unused color is \(nextColor)")
            node.color = nextColor
            print("Setting color of \(node.id) to \(nextColor)")
            if nextColor == Color.error
                {
                throw(ColoringError.notEnoughColors)
                }
            }
        for node in self.nodes.values
            {
            print("Color of node \(node.id) is \(node.color)")
            }
        }
    }

extension Array where Element == Graph.Node
    {
    func withoutFirst() -> Array<Element>
        {
        return(Array(self.dropFirst()))
        }
    }


let graph = Graph()
graph.initGraph()
do
    {
    try graph.colorGraph()
    }
catch let error
    {
    print("Error is \(error)")
    }
