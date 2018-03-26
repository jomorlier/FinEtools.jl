"""
    MeshTetrahedronModule

Module  for generation of meshes composed of tetrahedra.
"""
module MeshTetrahedronModule

using FinEtools.FTypesModule: FInt, FFlt, FCplxFlt, FFltVec, FIntVec, FFltMat, FIntMat, FMat, FVec, FDataDict
import FinEtools.FESetModule: count, FESetT4, FESetT10, setlabel!
import FinEtools.FENodeSetModule: FENodeSet
import FinEtools.MeshUtilModule: makecontainer, addhyperface!, findhyperface!, linearspace
import FinEtools.MeshSelectionModule: selectelem

"""
    T4block(Length::FFlt, Width::FFlt, Height::FFlt,
       nL::FInt, nW::FInt, nH::FInt, orientation::Symbol)

Generate a tetrahedral mesh  of the 3D block.

Four-node tetrahedra in a regular arrangement, with uniform spacing between
the nodes, with a given orientation of the diagonals.

The mesh is produced by splitting each logical  rectangular cell into six
tetrahedra.
Range =<0, Length> x <0, Width> x <0, Height>
Divided into elements: nL,  nW,  nH in the first,  second,  and
third direction (x, y, z).
"""
function T4block(Length::FFlt, Width::FFlt, Height::FFlt,
  nL::FInt, nW::FInt, nH::FInt, orientation::Symbol=:a)
    return T4blockx(collect(linearspace(0.0, Length, nL+1)),
                    collect(linearspace(0.0, Width, nW+1)),
                    collect(linearspace(0.0, Height, nH+1)), orientation);
end

"""
    T4blockx(xs::FFltMat, ys::FFltMat, zs::FFltMat, orientation::Symbol)

Generate a graded tetrahedral mesh  of a 3D block.

Four-node tetrahedra in a regular arrangement, with non-uniform given spacing
between the nodes, with a given orientation of the diagonals.

The mesh is produced by splitting each logical  rectangular cell into six
tetrahedra.
"""
function T4blockx(xs::FFltMat, ys::FFltMat, zs::FFltMat, orientation::Symbol)
    return T4blockx(vec(xs), vec(ys), vec(zs), orientation)
end

"""
    T4blockx(xs::FFltVec, ys::FFltVec, zs::FFltVec, orientation::Symbol)

Generate a graded tetrahedral mesh  of a 3D block.

Four-node tetrahedra in a regular arrangement, with non-uniform given spacing
between the nodes, with a given orientation of the diagonals.

The mesh is produced by splitting each logical  rectangular cell into six
tetrahedra.
"""
function T4blockx(xs::FFltVec, ys::FFltVec, zs::FFltVec, orientation::Symbol)
    nL =length(xs)-1;
    nW =length(ys)-1;
    nH =length(zs)-1;
    nnodes=(nL+1)*(nW+1)*(nH+1);
    ncells=6*(nL)*(nW)*(nH);
    xyzs=zeros(FFlt, nnodes, 3);
    conns=zeros(FInt, ncells, 4);
    if (orientation==:a)
        t4ia = [1  8  5  6; 3  4  2  7; 7  2  6  8; 4  7  8  2; 2  1  6  8; 4  8  1  2];
        t4ib = [1  8  5  6; 3  4  2  7; 7  2  6  8; 4  7  8  2; 2  1  6  8; 4  8  1  2];
    elseif (orientation==:b)
        t4ia = [2 7 5 6; 1 8 5 7; 1 3 4 8; 2 1 5 7; 1 2 3 7; 3 7 8 1];
        t4ib = [2 7 5 6; 1 8 5 7; 1 3 4 8; 2 1 5 7; 1 2 3 7; 3 7 8 1];
    elseif (orientation==:ca)
        t4ia = [8  4  7  5; 6  7  2  5; 3  4  2  7; 1  2  4  5; 7  4  2  5];
        t4ib = [7  3  6  8; 5  8  6  1; 2  3  1  6; 4  1  3  8; 6  3  1  8];
    elseif (orientation==:cb)
        t4ia = [7  3  6  8; 5  8  6  1; 2  3  1  6; 4  1  3  8; 6  3  1  8];
        t4ib = [8  4  7  5; 6  7  2  5; 3  4  2  7; 1  2  4  5; 7  4  2  5];
    else
        error("Unknown orientation")
    end
    f=1;
    for k=1:(nH+1)
        for j=1:(nW+1)
            for i=1:(nL+1)
                xyzs[f, 1] = xs[i]
                xyzs[f, 2] = ys[j]
                xyzs[f, 3] = zs[k];
                f=f+1;
            end
        end
    end

    fens=FENodeSet(xyzs);

    function node_numbers(i::FInt, j::FInt, k::FInt, nL::FInt, nW::FInt, nH::FInt)
        f=(k-1)*((nL+1)*(nW+1))+(j-1)*(nL+1)+i;
        nn=[f (f+1)  f+(nL+1)+1 f+(nL+1)];
        return [nn broadcast(+, nn, (nL+1)*(nW+1))];
    end

    gc=1;
    for i=1:nL
        for j=1:nW
            for k=1:nH
                nn=node_numbers(i, j, k, nL, nW, nH);
                if (mod(sum( [i, j, k] ), 2)==0)
                    t4i =t4ib;
                else
                    t4i =t4ia;
                end
                for r=1:size(t4i, 1)
                    for c1=1:size(t4i, 2)
                        conns[gc, c1] = nn[t4i[r, c1]];
                    end
                    gc=gc+1;
                end
            end
        end
    end
    fes = FESetT4(conns[1:gc-1, :]);

    return fens, fes
end

"""
    T4toT10(fens::FENodeSet,  fes::FESetT4)

Convert a mesh of tetrahedra of type T4 (four-node) to tetrahedra T10.
"""
function  T4toT10(fens::FENodeSet,  fes::FESetT4)
    nedges=6;
    ec = [1  2; 2  3; 3  1; 4  1; 4  2; 4  3];
    # Additional node numbers are numbered from here
    newn = count(fens)+1;
    # make a search structure for edges
    edges = makecontainer();
    for i= 1:length(fes.conn)
        for J = 1:nedges
            ev=fes.conn[i][ec[J,:]];
            newn = addhyperface!(edges,  ev,  newn);
        end
    end
    xyz1 =fens.xyz;             # Pre-existing nodes
    # Allocate for vertex nodes plus edge nodes plus face nodes
    xyz =zeros(FFlt, newn-1, 3);
    xyz[1:size(xyz1, 1), :] = xyz1; # existing nodes are copied over
    # calculate the locations of the new nodes
    # and construct the new nodes
    for i in keys(edges)
        C=edges[i];
        for J = 1:length(C)
          ix = vec([item for item in C[J].o])
          push!(ix,  i) # Add the anchor point as well
          xyz[C[J].n, :] = mean(xyz[ix, :], dims = 1);
        end
    end
    fens = FENodeSet(xyz);
    # construct new geometry cells
    nconn=zeros(FInt, length(fes.conn), 10);
    nc=1;
    for i= 1:length(fes.conn)
        econn=zeros(FInt, 1, nedges);
        for J = 1:nedges
            ev=fes.conn[i][ec[J,:]];
            h, n=findhyperface!(edges,  ev);
            econn[J]=n;
        end
        wn = 1
        for j in fes.conn[i]
            nconn[nc, wn] = j; wn = wn + 1
        end
        for j in econn
            nconn[nc, wn] = j; wn = wn + 1
        end
        # nconn[nc, :] = vcat([j for j in fes.conn[i]], vec(econn))
        nc= nc+ 1;
    end
    labels = deepcopy(fes.label)
    fes = FESetT10(nconn);
    fes = setlabel!(fes, labels)
    return fens, fes;
end

"""
    T10block(Length::FFlt, Width::FFlt, Height::FFlt,
      nL::FInt, nW::FInt, nH::FInt; orientation::Symbol=:a)

Generate a tetrahedral  mesh of T10 elements  of a rectangular block.
"""
function T10block(Length::FFlt, Width::FFlt, Height::FFlt,
    nL::FInt, nW::FInt, nH::FInt; orientation::Symbol=:a)
    fens, fes = T4block(Length, Width, Height, nL, nW, nH, orientation);
    fens, fes = T4toT10(fens, fes);
    return fens, fes
end

"""
    T10blockx(xs::FFltMat, ys::FFltMat, zs::FFltMat, orientation::Symbol = :a)

Generate a graded 10-node tetrahedral mesh  of a 3D block.

10-node tetrahedra in a regular arrangement, with non-uniform given spacing
between the nodes, with a given orientation of the diagonals.

The mesh is produced by splitting each logical  rectangular cell into six
tetrahedra.
"""
function T10blockx(xs::FFltMat, ys::FFltMat, zs::FFltMat, orientation::Symbol = :a)
    fens, fes =  T4blockx(vec(xs), vec(ys), vec(zs), orientation)
    fens, fes = T4toT10(fens, fes);
    return fens, fes
end

function T10blockx(xs::FFltVec, ys::FFltVec, zs::FFltVec, orientation::Symbol = :a)
    fens, fes =  T4blockx(vec(xs), vec(ys), vec(zs), orientation)
    fens, fes = T4toT10(fens, fes);
    return fens, fes
end

"""
    T10layeredplatex(xs::FFltVec, ys::FFltVec, ts::FFltVec, nts::FIntVec,
        orientation::Symbol = :a)

T10 mesh for a layered block (composite plate) with specified in plane coordinates.

xs,ys =Locations of the individual planes of nodes.
ts= Array of layer thicknesses,
nts= array of numbers of elements per layer

The finite elements of each layer are labeled with the layer number, starting
from 1 at the bottom.
"""
function T10layeredplatex(xs::FFltVec, ys::FFltVec, ts::FFltVec, nts::FIntVec,
    orientation::Symbol = :a)
    tolerance = minimum(abs.(ts))/maximum(nts)/10.;
    @assert length(ts) >= 1
    @assert sum(nts) >= length(ts)
    zs = collect(linearspace(0.0, ts[1], nts[1]+1))
    for layer = 2:length(ts)
        oz = collect(linearspace(sum(ts[1:layer-1]), sum(ts[1:layer]), nts[layer]+1))
        zs = vcat(zs, oz[2:end])
    end
    fens, fes = T4blockx(xs, ys, zs, orientation);
    List = selectelem(fens, fes, box = [-Inf Inf -Inf Inf 0.0 ts[1]], inflate = tolerance)
    fes.label[List] = 1
    for layer = 2:length(ts)
        List = selectelem(fens, fes, box = [-Inf Inf -Inf Inf sum(ts[1:layer-1]) sum(ts[1:layer])],
            inflate = tolerance)
        fes.label[List] = layer
    end
    fens, fes =  T4toT10(fens, fes)
    return fens, fes
end

"""
    tetv(X)

Compute the volume of a tetrahedron.

```
X = [0  4  3
9  2  4
6  1  7
0  1  5] # for these points the volume is 10.0
tetv(X)
```
"""
function tetv(X::FFltMat)
    local one6th = 1.0/6
    # @assert size(X, 1) == 4
    # @assert size(X, 2) == 3
    @inbounds let
        A1 = X[2,1]-X[1,1];
        A2 = X[2,2]-X[1,2];
        A3 = X[2,3]-X[1,3];
        B1 = X[3,1]-X[1,1];
        B2 = X[3,2]-X[1,2];
        B3 = X[3,3]-X[1,3];
        C1 = X[4,1]-X[1,1];
        C2 = X[4,2]-X[1,2];
        C3 = X[4,3]-X[1,3];
        return one6th * ((-A3*B2+A2*B3)*C1 +  (A3*B1-A1*B3)*C2 + (-A2*B1+A1*B2)*C3);
    end
end

function tetv(v11::FFlt, v12::FFlt, v13::FFlt, v21::FFlt, v22::FFlt, v23::FFlt, v31::FFlt, v32::FFlt, v33::FFlt, v41::FFlt, v42::FFlt, v43::FFlt)
    local one6th = 1.0/6
    @inbounds let
        A1 = v21 - v11;
        A2 = v22 - v12;
        A3 = v23 - v13;
        B1 = v31 - v11;
        B2 = v32 - v12;
        B3 = v33 - v13;
        C1 = v41 - v11;
        C2 = v42 - v12;
        C3 = v43 - v13;
        return one6th * ((-A3*B2+A2*B3)*C1 +  (A3*B1-A1*B3)*C2 + (-A2*B1+A1*B2)*C3);
    end
end

"""
    tetv1times6(v, i1, i2, i3, i4)

Compute 6 times the volume of the tetrahedron.
"""
function tetv1times6(v::FFltMat, i1::Int, i2::Int, i3::Int, i4::Int)
    # local one6th = 1.0/6
    # @assert size(X, 1) == 4
    # @assert size(X, 2) == 3
    @inbounds let
        A1 = v[i2,1]-v[i1,1];
        A2 = v[i2,2]-v[i1,2];
        A3 = v[i2,3]-v[i1,3];
        B1 = v[i3,1]-v[i1,1];
        B2 = v[i3,2]-v[i1,2];
        B3 = v[i3,3]-v[i1,3];
        C1 = v[i4,1]-v[i1,1];
        C2 = v[i4,2]-v[i1,2];
        C3 = v[i4,3]-v[i1,3];
        return ((-A3*B2+A2*B3)*C1 +  (A3*B1-A1*B3)*C2 + (-A2*B1+A1*B2)*C3);
    end
end

"""
    T4meshedges(t::Array{Int, 2})

Compute all the edges of the 4-node triangulation.
"""
function T4meshedges(t::Array{Int, 2})
    @assert size(t, 2) == 4
    ec = [  1  2
            2  3
            3  1
            4  1
            4  2
            4  3];
    e = vcat(t[:,ec[1,:]], t[:,ec[2,:]], t[:,ec[3,:]], t[:,ec[4,:]], t[:,ec[5,:]], t[:,ec[6,:]])
    e = sort(e; dims = 2);
    ix = sortperm(e[:,1]);
    e = e[ix,:];
    ue = deepcopy(e)
    i = 1;
    n=1;
    while n <= size(e,1)
        c = ue[n,1];
        m = n+1;
        while m <= size(e,1)
            if (ue[m,1] != c)
                break;
            end
            m = m+1;
        end
        us = unique(ue[n:m-1,2], 1);
        ls =length(us);
        e[i:i+ls-1,1] = c;
        e[i:i+ls-1,2] = sort(us);
        i = i+ls;
        n = m;
    end
    e = e[1:i-1,:];
end


# Construct arrays to describe a hexahedron mesh created from voxel image.
#
# img = 3-D image (array),  the voxel values  are arbitrary
# voxval =range of voxel values to be included in the mesh,
# voxval =  [minimum value,  maximum value].  Minimum value == maximum value is
# allowed.
# Output:
# t = array of hexahedron connectivities,  one hexahedron per row
# v =Array of vertex locations,  one vertex per row
function T4voximggen(img::Array{DataT, 3},  voxval::Array{DataT, 1}) where {DataT<:Number}
    M=size(img,  1); N=size(img,  2); P=size(img,  3);
    t4ia = [8 4 7 5; 6 7 2 5; 3 4 2 7; 1 2 4 5; 7 4 2 5];
    t4ib = [7 3 6 8; 5 8 6 1; 2 3 1 6; 4 1 3 8; 6 3 1 8];

    function find_nonempty(minvoxval, maxvoxval)
        Nvoxval=0
        for I= 1:M
            for J= 1:N
                for K= 1:P
                    if (img[I, J, K]>=minvoxval) && (img[I, J, K]<=maxvoxval)
                        Nvoxval=Nvoxval+1
                    end
                end
            end
        end
        return Nvoxval
    end
    minvoxval= minimum(voxval)  # include voxels at or above this number
    maxvoxval= maximum(voxval)  # include voxels at or below this number
    Nvoxval =find_nonempty(minvoxval, maxvoxval) # how many "full" voxels are there?

    # Allocate output arrays:  one voxel is converted to 5 tetrahedra
    t =zeros(FInt, 5*Nvoxval, 4);
    v =zeros(FInt, (M+1)*(N+1)*(P+1), 3);
    tmid =zeros(FInt, 5*Nvoxval);

    Slice =zeros(FInt, 2, N+1, P+1); # auxiliary buffer
    function find_vertex(I, IJK)
        vidx = zeros(FInt, 1, size(IJK, 1));
        for r= 1:size(IJK, 1)
            if (Slice[IJK[r, 1], IJK[r, 2], IJK[r, 3]]==0)
                nv=nv+1;
                v[nv, :] =IJK[r, :]; v[nv, 1] += I-1;
                Slice[IJK[r, 1], IJK[r, 2], IJK[r, 3]] =nv;
            end
            vidx[r] =Slice[IJK[r, 1], IJK[r, 2], IJK[r, 3]];
        end
        return vidx
    end
    function store_elements(I, J, K)
        locs =[1 J K;1+1 J K;1+1 J+1 K;1 J+1 K;1 J K+1;1+1 J K+1;1+1 J+1 K+1;1 J+1 K+1];
        vidx = find_vertex(I, locs);
        for r=1:5
        nt =nt +1;
        if (mod(sum( [I,J,K] ),2) == 0)
            t[nt,:] = vidx[t4ia[r,:]];
        else
            t[nt,:] = vidx[t4ib[r,:]];
        end
        tmid[nt] = convert(FInt, img[I, J, K]);
    end

    end

    nv =0;                      # number of vertices
    nt =0;                      # number of elements
    for I= 1:M
        for J= 1:N
            for K= 1:P
                if  (img[I, J, K]>=minvoxval) && (img[I, J, K]<=maxvoxval)
                    store_elements(I, J, K);
                end
            end
        end
        Slice[1, :, :] =Slice[2, :, :] ;
        Slice[2, :, :] =0;
    end
    # Trim output arrays
    v = v[1:nv, :];
    t = t[1:nt, :];
    tmid = tmid[1:nt];

    return t, v, tmid
end

"""
    T4voximg(img::Array{DataT, 3}, voxdims::FFltVec,
        voxval::Array{DataT, 1}) where {DataT<:Number}

Generate a tetrahedral mesh  from three-dimensional image.
"""
function T4voximg(img::Array{DataT, 3}, voxdims::FFltVec, voxval::Array{DataT, 1}) where {DataT<:Number}
    t, v, tmid = T4voximggen(img, voxval)
    xyz = zeros(FFlt, size(v, 1), 3)
    for k=1:3
        for j=1:size(v, 1)
            xyz[j, k] = v[j, k]*voxdims[k]
        end
    end
    fens  = FENodeSet(xyz);
    fes = FESetT4(t);
    setlabel!(fes, tmid)
    return fens, fes;
end

end
