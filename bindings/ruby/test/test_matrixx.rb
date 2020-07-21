require 'minitest/autorun'
require 'eigen'

class TC_Eigen_MatrixX < Minitest::Test
    def test_base
        m = Eigen::MatrixX.new(2,3)
        assert_equal(m.rows, 2)
        assert_equal(m.cols, 3)
        assert_equal(m.size, 6)
    end

    def test_new_zero
        m = Eigen::MatrixX.Zero(2, 2)
        2.times do |i|
            2.times do |j|
                assert_equal 0, m[i, j]
            end
        end
    end

    def test_zero
        m = Eigen::MatrixX.new(2, 2)
        m.zero
        2.times do |i|
            2.times do |j|
                assert_equal 0, m[i, j]
            end
        end
    end

    def test_new_identity
        m = Eigen::MatrixX.Identity(2, 2)
        2.times do |i|
            2.times do |j|
                assert_equal((i == j ? 1 : 0), m[i, j])
            end
        end
    end

    def test_identity
        m = Eigen::MatrixX.new(2, 2)
        m.identity
        2.times do |i|
            2.times do |j|
                assert_equal((i == j ? 1 : 0), m[i, j])
            end
        end
    end

    def test_set
        m = Eigen::MatrixX.new(2,2)
        m[0,0]=2.0
        m[1,0]=1.0
        m[0,1]=-1.0
        m[1,1]=-2.0
        assert_equal(m.to_a,[2.0,1.0,-1.0,-2.0])
        m2 = Eigen::MatrixX.new(2,2)
        m2.from_a(m.to_a,2,2)
        assert_equal(m, m2)
    end

    def test_set_from_a
        m = Eigen::MatrixX.new(2,3)
        m.from_a([0,1,2,3,4,5],2,3)
        assert_equal(m[0,0],0.0)
        assert_equal(m[1,0],1.0)
        assert_equal(m[0,1],2.0)
        assert_equal(m[1,1],3.0)
        assert_equal(m[0,2],4.0)
        assert_equal(m[1,2],5.0)
    end

    def test_set_row
        m = Eigen::MatrixX.new(3,4)
        v = Eigen::VectorX.new(4)
        v.from_a([-3.1,-4.2,5.3,6.4])
        m.setRow(0,v)
        m.setRow(2,v)
        v2 = Eigen::VectorX.new(4)
        v2.from_a([1.0,2.0,3.0,4.0])
        m.setRow(1, v2)
        assert_equal(m.row(0).to_a, v.to_a)
        assert_equal(m.row(2).to_a, v.to_a)
        assert_equal(m.row(1).to_a, v2.to_a)
    end

    def test_set_col_add
        m = Eigen::MatrixX.new(2,2)
        v = Eigen::VectorX.new(2)
        v.from_a([1.0,0.0])
        v2 = Eigen::VectorX.new(2)
        v2.from_a([10.0,20.0])
        m.setCol(0,v)
        m.setCol(1,v2)
        assert_equal(m.to_a, [1.0, 0.0, 10.0, 20.0])
        v3 = Eigen::VectorX.new(2)
        v3[0] = 11.0
        v3[1] = 20.0
        assert_equal(v3,v+v2)
    end

    def test_from_a_col_row_major
        m = Eigen::MatrixX.new(2,2)
        a = [0,1,2,3]

        m.from_a(a,2,2,true)
        assert_equal(m[0,0],0)
        assert_equal(m[1,0],1)
        assert_equal(m[0,1],2)
        assert_equal(m[1,1],3)

        m.from_a(a,2,2,false)
        assert_equal(m[0,0],0)
        assert_equal(m[0,1],1)
        assert_equal(m[1,0],2)
        assert_equal(m[1,1],3)
    end

    def test_matrix_dump_load
        m = Eigen::MatrixX.new(9,7)
        l = 9*7
        for i in 0..l-1
            m[i%9,i/9] = i
        end
        dumped = Marshal.dump(m)
        loaded = Marshal.load(dumped)
        assert m.approx?(loaded)
    end

    def test_dup
        m = Eigen::MatrixX.new(9,7)
        l = 9*7
        for i in 0..l-1
            m[i%9,i/9] = i + 1
        end
        assert m.approx?(m.dup)
    end

    def test_dotV
        m = Eigen::MatrixX.Zero(4, 4)
        4.times { |i| m[i, i] = i + 1 }
        a = Eigen::VectorX.from_a([1, 2, 3, 4])
        b = m.dotV(a)
        expected = Eigen::VectorX.from_a([1, 4, 9, 16])
        assert_kind_of Eigen::VectorX, b
        assert expected.approx?(b, 1e-3),
               "expected #{b} to be approximately equal to #{expected}"
    end

    def test_jacobisvd
        m = Eigen::MatrixX.Zero(7, 7)
        7.times { |i| m[i, i] = i + 1 }
        solver = m.jacobiSvd(Eigen::ComputeThinU | Eigen::ComputeThinV)
        b = Eigen::VectorX.from_a([1, 2, 3, 4, 5, 6, 7])
        a = solver.solve(b)

        assert m.dotV(a).approx?(b)
    end
end
