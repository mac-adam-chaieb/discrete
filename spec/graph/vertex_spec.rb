require 'spec_helper'

describe Math::Discrete::Graph::Vertex do
  let(:vertex) { described_class.build_from_label 'A' }

  describe '::build_from_label' do
    it 'creates a new vertex with the given label and no adjacent vertices' do
      expect(vertex).to be_a described_class
      expect(vertex.label).to eq 'A'
      expect(vertex.adjacent_vertices).to be_empty
    end
  end

  describe '::build_from_labels' do
    let(:vertices) { described_class.build_from_labels 'A', 'B', 'C' }

    it 'creates a Set of vertices with the given labels and no adjacent vertices' do
      expect(vertices).to be_a Set
      expect(vertices.map &:label).to contain_exactly 'A', 'B', 'C'
      expect(vertices.map &:adjacent_vertices).to all be_empty
    end
  end

  describe '#add_adjacent_vertex' do
    let(:other_vertex) { described_class.build_from_label 'other' }

    it 'adds the given vertex to the vertex\'s set of adjacent vertices' do
      expect { vertex.send :add_adjacent_vertex, other_vertex }.to change(vertex.adjacent_vertices, :count).by(1)
      expect(vertex.adjacent_vertices).to include other_vertex
    end
  end

  describe '#remove_adjacent_vertex' do
    let(:other_vertex) { described_class.build_from_label 'other' }

    it 'removes the given vertex from the vertex\'s set of adjacent vertices' do
      vertex.send :add_adjacent_vertex, other_vertex

      expect { vertex.send :remove_adjacent_vertex, other_vertex }.to change(vertex.adjacent_vertices, :count).by(-1)
      expect(vertex.adjacent_vertices).not_to include other_vertex
    end
  end

  describe '#adjacent_to?' do
    let(:other_vertex) { described_class.build_from_label 'other' }

    it 'returns true if the other vertex is part of the vertex\'s set of adjacent vertices' do
      vertex.send :add_adjacent_vertex, other_vertex

      expect(vertex).to be_adjacent_to other_vertex
    end

    it 'returns false if the other vertex is not part of the vertex\'s set of adjacent vertices' do
      expect(vertex).not_to be_adjacent_to other_vertex
    end

    it 'raises a TypeError if the input is an object of a non-Vertex type' do
      expect { vertex.adjacent_to? 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end
  end

  describe '#==' do
    let(:same_vertex) { described_class.build_from_label 'A' }
    let(:different_vertex) { described_class.build_from_label 'B'}

    it 'returns true if compared with itself' do
      expect(vertex).to eq vertex
    end

    it 'returns true if compared to vertex with the same label' do
      expect(vertex).to eq same_vertex
      expect(same_vertex).to eq vertex
    end

    it 'returns false if compared to a vertex with a different label' do
      expect(vertex).not_to eq different_vertex
      expect(different_vertex).not_to eq vertex
    end

    it 'raises a TypeError when compared to an object of non-Vertex type' do
      expect { vertex == 'This is not a vertex' }.to raise_error Math::Discrete::TypeError
    end
  end
end