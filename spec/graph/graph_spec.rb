require 'spec_helper'

describe Math::Discrete::Graph do
  let(:labels) { [1, 2] }

  describe '#[]' do
    let(:graph) { Graph[[1, 2, 3], [[1, 2], [2, 3], [3, 1], [1, 3]]] }
    let(:vertex_result) { graph[1] }
    let(:edge_result) { graph[2, 3] }

    it 'returns the vertex with the corresponding label' do
      expect(vertex_result).to be_an_instance_of Vertex
      expect(vertex_result.label).to be 1
    end

    it 'returns the edge with the corresponing labels' do
      expect(edge_result).to be_an_instance_of Edge
      expect(edge_result.labels).to contain_exactly 2, 3
    end

    it 'returns nil if no vertex or edge have the given labels' do
      expect(graph['hello']).to be_nil
    end
  end

  describe '#<<' do
    context 'with a vertex' do
      let(:graph) { Graph[] }
      let(:vertex) { Vertex[labels.first] }

      it 'adds the vertex to the vertex set' do
        graph << vertex
        expect(graph.vertex_set).to include vertex
      end

      it 'raises a TypeError if the input is not a Vertex' do
        expect {
          graph << 'This is not a vertex'
        }.to raise_error TypeError
      end

      it 'raises a VertexNotUnique if the input is a vertex that is already in the vertex set' do
        graph << vertex

        expect {
          graph << vertex
        }.to raise_error Graph::VertexNotUnique
      end
    end

    context 'with an edge' do
      let(:vertices) { Vertex::Set[*labels] }
      let(:graph) { Graph[vertices] }
      let(:edge) { Edge[*vertices] }

      it 'adds the edge to the edge set' do
        graph << edge
        expect(graph.edge_set).to include edge
      end

      it 'raises a EdgeNotUnique if the input is an edge that is already in the edge set' do
        expect {
          graph  << 'This is not an edge'
        }.to raise_error TypeError
      end

      it 'raises a EdgeNotUnique if the input is a edge that is already in the edge set' do
        graph << edge

        expect {
          graph << edge
        }.to raise_error Graph::EdgeNotUnique
      end
    end
  end

  describe '::[]' do
    let(:vertex_set) { Vertex::Set['A', 'B', 'C'] }
    let(:edge_set) do
      Edge::Set[
        [vertex_set.entries[0], vertex_set.entries[1]],
        [vertex_set.entries[1], vertex_set.entries[0]],
        [vertex_set.entries[1], vertex_set.entries[2]],
        [vertex_set.entries[2], vertex_set.entries[1]]
      ]
    end

    let(:graph_from_sets) { Graph[vertex_set, edge_set] }
    let(:graph_from_labels) { Graph[[1, 2, 3], [[1, 2], [2, 3], [3, 1], [1, 3]]] }

    it 'raises a TypeError if the given vertex set or label set is not a Set or an Array' do
      expect {
        Graph['vertices', []]
      }.to raise_error TypeError
    end

    it 'raises a TypeError if the given edge set or label set is not a Set or an Array' do
      expect {
        Graph[[], 'edges']
      }.to raise_error TypeError
    end

    it 'builds a graph from the given vertex set and edge set' do
      expect(graph_from_sets).to be_an_instance_of Graph
      expect(graph_from_sets.vertex_set).to eq vertex_set
      expect(graph_from_sets.edge_set).to eq edge_set
    end

    it 'builds a graph from the given vertex label set and edge label set' do
      expect(graph_from_labels).to be_an_instance_of Graph
      expect(graph_from_labels.vertex_labels).to contain_exactly 1, 2, 3
    end
  end

  describe '#add_vertex!, #add_node!' do
    let(:graph) { Graph[] }
    let(:vertex) { Vertex['A'] }

    it 'adds the vertex to the vertex set' do
      graph.add_vertex! vertex
      expect(graph.vertex_set).to include vertex
    end

    it 'raises a TypeError if the input is an object of a non-Vertex type' do
      expect {
        graph.add_vertex! 'This is not a vertex'
      }.to raise_error TypeError
    end

    it 'raises a VertexNotUnique if the vertex is already part of the vertex set' do
      graph.add_vertex! vertex

      expect {
        graph.add_vertex! vertex
      }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_vertices!, #add_nodes!' do
    let(:graph) { Graph[] }
    let(:vertices) { Vertex::Set[*labels] }

    it 'adds the vertices to the vertex set' do
      graph.add_vertices! vertices
      expect(graph.vertex_set).to include *vertices
    end

    it 'raises a TypeError if the input includes an object of a non-Vertex type' do
      expect {
        graph.add_vertices!(vertices << 'This is not a vertex')
      }.to raise_error TypeError
    end

    it 'raises a VertexNotUnique if the input includes a vertex that is already part of the vertex set' do
      graph.add_vertex! vertices.first

      expect {
        graph.add_vertices! vertices
      }.to raise_error Graph::VertexNotUnique
    end
  end

  describe '#add_edge!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices, []] }
    let(:edge) { Edge[*vertices] }

    it 'adds the edge to the edge set' do
      graph.add_edge! edge
      expect(graph.edge_set).to include edge
    end

    it 'raises a TypeError if the input is an object of a non-Edge type' do
      expect {
        graph.add_edge! 'This is not an edge'
      }.to raise_error TypeError
    end

    it 'raises a EdgeNotUnique if the edge is already part of the edge set' do
      graph.add_edge! edge

      expect { graph.add_edge! edge }.to raise_error Graph::EdgeNotUnique
    end
  end

  describe '#add_edges!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices] }
    let(:edges) { Edge::Set[[*vertices]] }

    it 'adds the edges to the edge set' do
      graph.add_edges! edges
      expect(graph.edge_set).to include *edges
    end

    it 'raises a TypeError if the input includes an object of a non-Edge type' do
      expect {
        graph.add_edges!(edges << 'This is not an edge')
      }.to raise_error TypeError
    end

    it 'raises a EdgeNotUnique if the input includes an edge that is already part of the edge set' do
      graph.add_edge! edges.first

      expect { graph.add_edges! edges }.to raise_error Graph::EdgeNotUnique
    end
  end

  describe '#remove_vertex!, #remove_node!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:vertex) { vertices.first }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the vertex from the vertex set' do
      graph.remove_vertex! vertex
      expect(graph.vertex_set).not_to include vertex
    end

    it 'removes the edges incident to the vertex from the edge set' do
      graph.remove_vertex! vertex
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect {
        graph.remove_vertex! 'This is not a vertex'
      }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Vertex['Z']

      expect { graph.remove_vertex! foreign_vertex }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_vertices!, #remove_nodes!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:vertex) { vertices.first }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the vertices from the vertex set' do
      graph.remove_vertices! vertices
      expect(graph.vertex_set).not_to include *vertices
    end

    it 'removes the edges incident to the vertices from the edge set' do
      graph.remove_vertices! vertices
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Vertex type' do
      expect {
        graph.remove_vertices! %w(This is not a vertex)
      }.to raise_error TypeError
    end

    it 'raises a VertexNotFound if the input is a vertex that is not part of the vertex set' do
      foreign_vertex = Vertex['Z']

      expect { graph.remove_vertices! vertices.add(foreign_vertex) }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#remove_edge!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the edge from the edge set' do
      graph.remove_edge! edge
      expect(graph.edge_set).not_to include edge
    end

    it 'raises a TypeError if the input is an object of non-Edge type' do
      expect {
        graph.remove_edge! 'This is not a vertex'
      }.to raise_error TypeError
    end

    it 'raises an EdgeNotFound if the input is an edge that is not part of the edge set' do
      foreign_edge = Edge[*vertices]

      expect { graph.remove_edge! foreign_edge }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#remove_edges!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }

    it 'removes the edge from the edge set' do
      graph.remove_edges! edges
      expect(graph.edge_set).not_to include *edge
    end

    it 'raises a TypeError if the input includes an an object of non-Edge type' do
      expect {
        graph.remove_edges! %w(This is not an edge)
      }.to raise_error TypeError
    end

    it 'raises an EdgeNotFound if the input includes an edge that is not part of the edge set' do
      foreign_edge = Edge[*vertices]

      expect { graph.remove_edges! [foreign_edge] }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#find_vertex_by_label!' do
    let(:vertex) { Vertex[1] }
    let(:graph) { Graph[[vertex], []] }

    it 'returns the vertex with the given label in the vertex set' do
      result = graph.find_vertex_by_label! 1

      expect(result).to be_an_instance_of Vertex
      expect(result.label).to eq 1
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with the given label' do
      expect { graph.find_vertex_by_label! 'Z' }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#find_vertices_by_labels!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices, []]}
    let(:result) { graph.find_vertices_by_labels! *labels }

    it 'returns the vertices with the given labels in the vertex set' do
      expect(result).to be_an_instance_of Set
      expect(result).to all be_an_instance_of Vertex
      expect(result.size).to be 2
      expect(result.map &:label).to contain_exactly *labels
    end

    it 'raises VertexNotFound if the vertex set does not include a vertex with one of the given labels' do
      expect { graph.find_vertices_by_labels! 'C', 'D' }.to raise_error Graph::VertexNotFound
    end
  end

  describe '#find_edge_by_labels!' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:edge) { edges.first }
    let(:graph) { Graph[vertices, edges] }
    let(:result) { graph.find_edge_by_labels! *labels }

    it 'returns the edge with the given labels in order in the edge set' do
      expect(result).to be_an_instance_of Edge
      expect(result.labels).to contain_exactly *labels
    end

    it 'raises EdgeNotFound if the edge set does not include an edge with the given labels' do
      expect { graph.find_edge_by_labels! 'X', 'Y' }.to raise_error Graph::EdgeNotFound
    end
  end

  describe '#vertex_labels' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:graph) { Graph[vertices, []] }

    it 'returns a set of all the vertex labels' do
      expect(graph.vertex_labels).to contain_exactly *labels
    end
  end

  describe '#edge_labels' do
    let(:vertices) { Vertex::Set[*labels] }
    let(:edges) { Edge::Set[[*vertices]] }
    let(:graph) { Graph[vertices, edges] }

    it 'returns a set of all the edge labels' do
      expect(graph.edge_labels).to contain_exactly *edges.map(&:labels)
      expect(graph.edge_labels).to be_an_instance_of Set
    end
  end

  describe 'properties' do
      let(:graph) { Graph[[1,2,3,4], [[1,2],[2,3],[3,1], [1,4], [4,2]]] }
      let(:complete_graph) { Graph[[*(1..5)], (1..5).to_a.permutation(2).to_a] }
      let(:even_cycle) { Graph[[*(1..10)], [*((1..10).each_cons(2).to_a << [10,1])]] }
      let(:odd_cycle) { Graph[[*(1..7)], [*((1..7).each_cons(2).to_a << [7,1])]] }
      let(:tree) { Graph[(1..7).to_a, [[1,2], [1,3], [2,4], [2,5], [3,6], [3,7]]] }

    describe '::bipartiteness' do
      it 'returns false early if the graph contains too many edges to possibly be bipartite' do
        expect(complete_graph).to receive(:breadth_first_search).never

        expect(complete_graph).not_to be_bipartite
      end

      it 'returns true if the graph is an even cycle' do
        expect(even_cycle).to be_bipartite
      end

      it 'returns false if the graph is an odd cycle' do
        expect(odd_cycle).not_to be_bipartite
      end

      it 'returns true if the graph is a tree' do
        expect(tree).to be_bipartite
      end
    end

    describe '::completeness' do
      it 'returns true if and only if every vertex is adjacent to every other vertex in the graph' do
        expect(complete_graph).to be_complete
      end

      it 'returns false if there is a vertex that is not adjacent to all other vertices in the graph' do
        expect(graph).not_to be_complete
      end
    end

    describe '::regularity' do
      it 'returns true if each vertex has the same number of adjacent vertices as all other vertices in the graph' do
        expect(even_cycle).to be_regular
      end

      it 'returns false if there are two vertices that does not have the same number of adjacent vertices in the graph' do
        expect(graph).not_to be_regular
      end
    end

    describe '::weightedness' do
      let(:weighted_graph) { Graph[[1,2], [[1,2,3], [2,1,2]]] }
      it 'returns false if all edges of the graph have the same weight' do
        expect(graph).not_to be_weighted
      end

      it 'returns true if some edge has a different weight than another edge in the graph' do
        expect(weighted_graph).to be_weighted
      end
    end
  end
end
