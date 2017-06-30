
module mmmmmmmmmmrrigid
using FinEtools
using Base.Test
function test()

# println("""
#
# Example from Boundary element acoustics: Fundamentals and computer codes, TW Wu, page 123.
# Internal resonance problem. Reference frequencies: 90.7895, 181.579, 215.625, 233.959, 272.368, 281.895
# Quadrilateral mesh.
# """)

t0 = time()

rho=1.21*1e-9;# mass density
c =345.0*1000;# millimeters per second
bulk= c^2*rho;
Lx=1900.0;# length of the box, millimeters
Ly=800.0; # length of the box, millimeters
n=14;#
neigvs=18;
OmegaShift=10.0;

fens,fes = Q4block(Lx,Ly,n,n); # Mesh

geom = NodalField(fens.xyz)
P = NodalField(zeros(size(fens.xyz,1),1))

numberdofs!(P)

femm = FEMMAcoust(GeoD(fes, GaussRule(2, 2)),
                     MatAcoustFluid(bulk,rho))

S = acousticstiffness(femm, geom, P);
C = acousticmass(femm, geom, P);

d,v,nev,nconv =eigs(C+OmegaShift*S, S; nev=neigvs, which=:SM)
d = d - OmegaShift;
fs=real(sqrt.(complex(d)))/(2*pi)
# println("Eigenvalues: $fs [Hz]")
#
#
# println("Total time elapsed = ",time() - t0,"s")
# println("$fs[2]-90.7895")
@test abs(fs[2]-90.9801) < 1e-4

File =  "rigid_box.vtk"
scalarllist = Any[]
for n  = 1:15
  push!(scalarllist, ("Pressure_mode_$n", v[:,n]));
end
vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.Q4;
          scalars=scalarllist)
sleep(1.0)
rm(File)
# @async run(`"paraview.exe" $File`)

true
end
end
using mmmmmmmmmmrrigid
mmmmmmmmmmrrigid.test()

module fahyL2example

using FinEtools
using Base.Test

function test()
# println("""
# Example from Sound and Structural Vibration, Second Edition: Radiation, Transmission and Response [Paperback]
# Frank J. Fahy, Paolo Gardonio, page 483.
#
# 1D mesh.
# """)

t0  =  time()

rho = 1.21*1e-9;# mass density
c  = 343.0*1000;# millimeters per second
bulk =  c^2*rho;
L = 500.0;# length of the box, millimeters
A = 200.0; # cross-sectional area of the box
graphics =  true;# plot the solution as it is computed?
n = 40;#
neigvs = 8;
OmegaShift = 10.0;

fens,fes  =  L2block(L,n); # Mesh

geom = NodalField(fens.xyz)
P = NodalField(zeros(size(fens.xyz,1),1))

numberdofs!(P)

femm = FEMMAcoust(GeoD(fes, GaussRule(1, 2)), MatAcoustFluid(bulk, rho))

S  =  acousticstiffness(femm, geom, P);
C  =  acousticmass(femm, geom, P);

d,v,nev,nconv  = eigs(C+OmegaShift*S, S; nev = neigvs, which = :SM)
d  =  d - OmegaShift;
fs = real(sqrt.(complex(d)))/(2*pi)
# println("Eigenvalues: $fs [Hz]")


# println("Total time elapsed  =  ",time() - t0,"s")

# using Plots
# plotly()
# en = 2
# ix = sortperm(geom.values[:])
# plot(geom.values[:][ix], v[:,en][ix], color = "blue",
# title = "Fahy example, mode $en" , xlabel = "x", ylabel = "P")
# gui()

  @test (fs[2]-343.08)/343.08 < 0.001

  #println("Total time elapsed = ",time() - t0,"s")

  # using Winston
  # en=2
  # pl = FramedPlot(title="Fahy example, mode $en",xlabel="x",ylabel="P")
  # setattr(pl.frame, draw_grid=true)
  # ix=sortperm(geom.values[:])
  # add(pl, Curve(geom.values[:][ix],v[:,en][ix], color="blue"))

  # display(pl)

  true
end
end
using fahyL2example
fahyL2example.test()

module mmfahyH8example
using FinEtools
using Base.Test
function test()

# println("""
# Example from Sound and Structural Vibration, Second Edition: Radiation, Transmission and Response [Paperback]
# Frank J. Fahy, Paolo Gardonio, page 483.
#
# Hexahedral mesh.
# """)

t0 = time()

rho=1.21*1e-9;# mass density
c =343.0*1000;# millimeters per second
bulk= c^2*rho;
L=500.0;# length of the box, millimeters
A=200.0; # cross-sectional area of the box
n=40;#
neigvs=8;
OmegaShift=10.0;

fens,fes = H8block(L,sqrt(A),sqrt(A),n,1,1); # Mesh

geom = NodalField(fens.xyz)
P = NodalField(zeros(size(fens.xyz,1),1))

numberdofs!(P)

femm = FEMMAcoust(GeoD(fes, GaussRule(3, 2)), MatAcoustFluid(bulk, rho))


S = acousticstiffness(femm, geom, P);
C = acousticmass(femm, geom, P);

d,v,nev,nconv = eigs(C+OmegaShift*S, S; nev=neigvs, which=:SM)
d = d - OmegaShift;
fs = real(sqrt.(complex(d)))/(2*pi)
# println("Eigenvalues: $fs [Hz]")
#
#
# println("Total time elapsed = ",time() - t0,"s")

# File =  "fahy_H8.vtk"
# en = 5;
# vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
#           scalars=[("Pressure_mode_$en", v[:,en])])
# println("Done")

  @test (fs[2]-343.08)/343.08 < 0.001

  true
end
end
using mmfahyH8example
mmfahyH8example.test()

module mmmmfahyH27example
using FinEtools
using Base.Test
function test()

# println("""
# Example from Sound and Structural Vibration, Second Edition: Radiation, Transmission and Response [Paperback]
# Frank J. Fahy, Paolo Gardonio, page 483.
#
# Hexahedral mesh.
# """)

t0 = time()

rho=1.21*1e-9;# mass density
c =343.0*1000;# millimeters per second
bulk= c^2*rho;
L=500.0;# length of the box, millimeters
A=200.0; # cross-sectional area of the box
n=40;#
neigvs=8;
OmegaShift=10.0;

fens,fes = H8block(L,sqrt(A),sqrt(A),n,1,1); # Mesh
fens,fes = H8toH27(fens,fes)

geom = NodalField(fens.xyz)
P = NodalField(zeros(size(fens.xyz,1),1))

numberdofs!(P)

femm = FEMMAcoust(GeoD(fes, GaussRule(3, 3)), MatAcoustFluid(bulk, rho))


S = acousticstiffness(femm, geom, P);
C = acousticmass(femm, geom, P);

d,v,nev,nconv = eigs(C+OmegaShift*S, S; nev=neigvs, which=:SM)
d = d - OmegaShift;
fs = real(sqrt.(complex(d)))/(2*pi)
# println("Eigenvalues: $fs [Hz]")
#
#
# println("Total time elapsed = ",time() - t0,"s")

# File =  "fahy_H8.vtk"
# en = 5;
# vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
#           scalars=[("Pressure_mode_$en", v[:,en])])
# println("Done")

  @test (fs[2]-343.08)/343.08 < 0.001

  true
end
end
using mmmmfahyH27example
mmmmfahyH27example.test()

module mmmmmstraight_duct_H8_1
using FinEtools
using Base.Test
function test()
    t0  =  time()

    rho = 1.21*phun("kg/m^3");# mass density
    c  = 343.0*phun("m/s");# sound speed
    bulk =  c^2*rho;
    omega =  54.5901*phun("rev/s")
    vn0 =  -1.0*phun("m/s")
    Lx = 10.0*phun("m");# length of the box, millimeters
    Ly = 1.0*phun("m"); # length of the box, millimeters
    n = 20;#number of elements along the length

    # println("""
    #
    # Straight duct with anechoic termination.
    # Example from Boundary element acoustics: Fundamentals and computer codes, TW Wu, page 44.
    # Both real and imaginary components of the pressure should have amplitude of
    # rho*c = $(rho*c).
    #
    # Hexahedral mesh.
    # """)

    fens,fes  =  H8block(Lx,Ly,Ly,n,2,2); # Mesh
    bfes  =  meshboundary(fes)
    L0 = selectelem(fens,bfes,facing = true, direction = [-1.0 0.0 0.0])
    L10 = selectelem(fens,bfes,facing = true, direction = [+1.0 0.0 0.0])
    nLx = selectnode(fens,box = [0.0 Lx  0.0 0.0 0.0 0.0], inflate = Lx/1.0e5)

    geom  =  NodalField(fens.xyz)
    P  =  NodalField(zeros(Complex128,size(fens.xyz,1),1))

    numberdofs!(P)


    material = MatAcoustFluid(bulk,rho)
    femm  =  FEMMAcoust(GeoD(fes, GaussRule(3, 2)), material)

    S  =  acousticstiffness(femm, geom, P);
    C  =  acousticmass(femm, geom, P);


    E10femm  =  FEMMAcoustSurf(GeoD(subset(bfes,L10),GaussRule(2, 2)), material)
    D  =  acousticABC(E10femm, geom, P);

    E0femm  =  FEMMBase(GeoD(subset(bfes,L0), GaussRule(2,  2)))
    fi  =  ForceIntensity(-1.0im*omega*rho*vn0);
    F  =  distribloads(E0femm, geom, P, fi, 2);

    p = (-omega^2*S +omega*1.0im*D + C)\F
    scattersysvec!(P, p[:])

    # println("Pressure amplitude bounds: ")
    # println("  real $(minimum(real(P.values)))/$(maximum(real(P.values)))")
    # println("  imag $(minimum(imag(P.values)))/$(maximum(imag(P.values)))")
    #
    # println("Total time elapsed  =  ",time() - t0,"s")

    File  =   "straight_duct.vtk"
    scalars = real(P.values);
    vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
    scalars = [("Pressure", scalars)])
    rm(File)
    # @async run(`"paraview.exe" $File`)

    ref=rho*c
    @test abs(minimum(real(P.values))-(-ref))/ref < 0.02
    @test abs(minimum(imag(P.values))-(-ref))/ref < 0.02
    @test abs(maximum(real(P.values))-(+ref))/ref < 0.02
    @test abs(maximum(imag(P.values))-(+ref))/ref < 0.02

    # plotly()
    # ix = sortperm(geom.values[nLx,1])
    # plot(geom.values[nLx,1][ix], real(P.values)[nLx][ix], color = :blue, label = "real")
    # plot!(geom.values[nLx,1][ix], imag(P.values)[nLx][ix], color = :red, label  =  "imag")
    # plot!(title = "Straight duct with anechoic termination",
    # xlabel = "x", ylabel = "Pressure")
    # gui()

    true

end
end
using mmmmmstraight_duct_H8_1
mmmmmstraight_duct_H8_1.test()

module mmmmmmmmmmsphere_dipole_1
using FinEtools
using Base.Test
function test()

# println("The interior sphere accelerates in the positive x-direction, generating
# positive pressure ahead of it, negative pressure behind
# ")
rho = 1.21*phun("kg/m^3");# mass density
c  = 343.0*phun("m/s");# sound speed
bulk =  c^2*rho;
a_amplitude=1.*phun("mm/s^2");# amplitude of the  acceleration of the sphere
# omega = 2000*phun("rev/s");      # frequency of the incident wave
R = 5.0*phun("mm"); # radius of the interior sphere
Ro = 4*R # radius of the external sphere
P_amplitude = R*rho*a_amplitude; # pressure amplitude
nref=2;
nlayers=40;
tolerance = Ro/(nlayers)/100
frequency=2000; # Hz
omega=2*pi*frequency;
k = omega/c*[1.0 0.0 0.0];

# println("""
#         Spherical domain filled with acoustic medium, no scatterer.
# Hexahedral mesh.
#         """)

t0  =  time()

# Hexahedral mesh
fens,fes  =  H8sphere(R,nref);
fens1,fes1  =  mirrormesh(fens, fes, [-1.0, 0.0, 0.0], [0.0, 0.0, 0.0],
renumb =  r(c) = c[[1, 4, 3, 2, 5, 8, 7, 6]]);
fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
fes = cat(newfes1,fes2)


# Derive the finite element sets for the boundary
bfes  =  meshboundary(fes)
# Outer spherical boundary
function dout(xyz)
    return xyz/norm(xyz)
end

louter = selectelem(fens, bfes, facing = true, direction = dout)
outer_fes = subset(bfes, louter);

fens,fes  = H8extrudeQ4(fens, outer_fes,
nlayers, (xyz, layer)->(R+layer/nlayers*(Ro-R))*xyz/norm(xyz));
connected = findunconnnodes(fens, fes);
fens, new_numbering = compactnodes(fens, connected);
fess = renumberconn!(fes, new_numbering);

geom  =  NodalField(fens.xyz)
P  =  NodalField(zeros(FCplxFlt,size(fens.xyz,1),1))

bfes  =  meshboundary(fes)

# File  =   "Sphere.vtk"
# vtkexportmesh(File, bfes.conn, geom.values, FinEtools.MeshExportModule.Q4)
# @async run(`"paraview.exe" $File`)

# File  =   "Sphere.vtk"
# vtkexportmesh (File, fes.conn, fens.xyz, MeshExportModule.H8)
# @async run(`"C:/Program Files (x86)/ParaView 4.2.0/bin/paraview.exe" $File`)

linner = selectelem(fens, bfes, distance = R, from = [0.0 0.0 0.0],
  inflate = tolerance)
louter = selectelem(fens, bfes, facing = true, direction = dout)

# println("Pre-processing time elapsed  =  ",time() - t0,"s")

t1  =  time()


numberdofs!(P)

material = MatAcoustFluid(bulk,rho)
femm  =  FEMMAcoust(GeoD(fes, GaussRule(3, 2)), material)

S  =  acousticstiffness(femm, geom, P);
C  =  acousticmass(femm, geom, P);

abcfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, louter), GaussRule(2, 2)), material)
D  =  acousticABC(abcfemm, geom, P);

# Inner sphere pressure loading
function dipole(dpdn, xyz, J, label)
    n = cross(J[:,1],J[:,2]);
    n = vec(n/norm(n));
    dpdn[1] = -rho*a_amplitude*n[1]
end

fi  =  ForceIntensity(FCplxFlt, 1, dipole);
#F  =  F - distribloads(pfemm, nothing, geom, P, fi, 2);
dipfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, linner), GaussRule(2, 2)), material)
F  = distribloads(dipfemm, geom, P, fi, 2);

K = lufact((1.0+0.0im)*(-omega^2*S + omega*1.0im*D + C)) # We fake a complex matrix here
p = K\F  #

scattersysvec!(P, p[:])

# println(" Minimum/maximum pressure= $(minimum(real(p)))/$(maximum(real(p)))")
@test abs(-minimum(real(p))-maximum(real(p))) < 1.0e-9
@test abs(3.110989923540772e-6-maximum(real(p))) < 1.0e-9
# println("Computing time elapsed  =  ",time() - t1,"s")
# println("Total time elapsed  =  ",time() - t0,"s")

File  =   "sphere_dipole_1.vtk"
vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
 scalars = [( "realP", real(P.values))])
rm(File)
# @async run(`"paraview.exe" $File`)

true
end
end
using mmmmmmmmmmsphere_dipole_1
mmmmmmmmmmsphere_dipole_1.test()

module mmmmmmmstraight_duct_T10_examplemmm
using FinEtools
using Base.Test
function test()

t0  =  time()

rho = 1.21*phun("kg/m^3");# mass density
c  = 343.0*phun("m/s");# sound speed
bulk =  c^2*rho;
omega =  54.5901*phun("rev/s")
vn0 =  -1.0*phun("m/s")
Lx = 10.0*phun("m");# length of the box, millimeters
Ly = 1.0*phun("m"); # length of the box, millimeters
n = 20;#number of elements along the length

# println("""
#
# Straight duct with anechoic termination.
# Example from Boundary element acoustics: Fundamentals and computer codes, TW Wu, page 44.
# Both real and imaginary components of the pressure should have amplitude of
# rho*c = $(rho*c).
#
# Tetrahedral (quadratic) mesh.
# """)

fens,fes  =  T10block(Lx,Ly,Ly,n,2,2); # Mesh
bfes  =  meshboundary(fes)
L0 = selectelem(fens,bfes,facing = true, direction = [-1.0 0.0 0.0])
L10 = selectelem(fens,bfes,facing = true, direction = [+1.0 0.0 0.0])
nLx = selectnode(fens,box = [0.0 Lx  0.0 0.0 0.0 0.0], inflate = Lx/1.0e5)

geom  =  NodalField(fens.xyz)
P  =  NodalField(zeros(Complex128,size(fens.xyz,1),1))

numberdofs!(P)


material = MatAcoustFluid(bulk,rho)
femm  =  FEMMAcoust(GeoD(fes, TetRule(4)), material)

S  =  acousticstiffness(femm, geom, P);
C  =  acousticmass(femm, geom, P);


E10femm  =  FEMMAcoustSurf(GeoD(subset(bfes,L10), TriRule(3)), material)
D  =  acousticABC(E10femm, geom, P);

E0femm  =  FEMMBase(GeoD(subset(bfes,L0), TriRule(3)))
fi  =  ForceIntensity(-1.0im*omega*rho*vn0);
F  =  distribloads(E0femm, geom, P, fi, 2);

p = (-omega^2*S +omega*1.0im*D + C)\F
scattersysvec!(P, p[:])

# println("Pressure amplitude bounds: ")
# println("  real $(minimum(real(P.values)))/$(maximum(real(P.values)))")
# println("  imag $(minimum(imag(P.values)))/$(maximum(imag(P.values)))")
#
# println("Total time elapsed  =  ",time() - t0,"s")
@test abs(-414.0986190028914-minimum(imag(P.values))) < 1.e-6

File  =   "straight_duct.vtk"
scalars = real(P.values);
vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.T10;
scalars = [("Pressure", scalars)])
# @async run(`"paraview.exe" $File`)
rm(File)

# plotly()
# ix = sortperm(geom.values[nLx,1])
# plot(geom.values[nLx,1][ix], real(P.values)[nLx][ix], color = :blue, label = "real")
# plot!(geom.values[nLx,1][ix], imag(P.values)[nLx][ix], color = :red, label  =  "imag")
# plot!(title = "Straight duct with anechoic termination",
# xlabel = "x", ylabel = "Pressure")
# gui()

true
end
end
using mmmmmmmstraight_duct_T10_examplemmm
mmmmmmmstraight_duct_T10_examplemmm.test()

module mmmmiintegrationmmmm
using FinEtools
using Base.Test
function test()
rho = 1000.*phun("kg/m^3");# mass density of water
c  = 1.4491e+3*phun("m/s");# sound speed in water
bulk =  c^2*rho;
rhos = 2500.*phun("kg/m^3");# mass density of the solid sphere
a_amplitude=1.*phun("mm/s^2");# amplitude of the  acceleration of the sphere
R = 5.0*phun("mm"); # radius of the interior sphere
Ro = 3*R # radius of the external sphere
# Mesh parameters, geometrical tolerance
nperR = 6;
nlayers=10;
tolerance = Ro/(nlayers)/100
# Hexahedral mesh of the solid sphere
fens,fes  =  H8spheren(R, nperR);
r(c) = c[[1, 4, 3, 2, 5, 8, 7, 6]]
fens1,fes1  =  mirrormesh(fens, fes, [-1.0, 0.0, 0.0], [0.0, 0.0, 0.0],
          renumb =  r);
fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
fes = cat(newfes1,fes2)
fens1,fes1  =  mirrormesh(fens, fes, [0.0, -1.0, 0.0], [0.0, 0.0, 0.0],
          renumb =  r);
fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
fes = cat(newfes1,fes2)
fens1,fes1  =  mirrormesh(fens, fes, [0.0, 0.0, -1.0], [0.0, 0.0, 0.0],
          renumb =  r);
fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
fes = cat(newfes1,fes2)

# Find the inertial properties of the solid sphere
geom  =  NodalField(fens.xyz)
femm  =  FEMMBase(GeoD(fes, GaussRule(3, 2)))
V = integratefunction(femm, geom, (x) ->  1.0)
  # println("V=$(V/phun("mm^3"))")
Sx = integratefunction(femm, geom, (x) ->  x[1])
  # println("Sx=$(Sx/phun("mm^4"))")
Sy = integratefunction(femm, geom, (x) ->  x[2])
  # println("Sy=$(Sy/phun("mm^4"))")
Sz = integratefunction(femm, geom, (x) ->  x[3])
  # println("Sz=$(Sz/phun("mm^4"))")
CG = vec([Sx Sy Sz]/V)
  # println("CG=$(CG/phun("mm"))")
function Iinteg(x)
  (norm(x-CG)^2*eye(3)-(x-CG)*(x-CG)')
end
Ixx = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 1])
Ixy = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 2])
Ixz = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 3])
Iyy = integratefunction(femm, geom, (x) ->  Iinteg(x)[2, 2])
Iyz = integratefunction(femm, geom, (x) ->  Iinteg(x)[2, 3])
Izz = integratefunction(femm, geom, (x) ->  Iinteg(x)[3, 3])
I = [Ixx Ixy Ixz; Ixy Iyy Iyz; Ixz Iyz Izz]
  # println("I=$(I/phun("mm^4"))")
@test abs(Ixx/phun("mm^4")-4.9809) < 0.001
mass =  V*rhos;
Inertia = I*rhos;
end
end
using mmmmiintegrationmmmm
mmmmiintegrationmmmm.test()

module mmmmmmtransientsphere
using FinEtools
using Base.Test
function test()
  # println("The interior sphere accelerates in the alternately in the positive
  # and negative x-direction, generating positive pressure ahead of it, negative
  # pressure behind. Time-dependent simulation.
  # ")
  rho = 1.21*phun("kg/m^3");# mass density
  c  = 343.0*phun("m/s");# sound speed
  bulk =  c^2*rho;
  a_amplitude=1.*phun("mm/s^2");# amplitude of the  acceleration of the sphere
  # omega = 2000*phun("rev/s");      # frequency of the incident wave
  R = 50.0*phun("mm"); # radius of the interior sphere
  Ro = 8*R # radius of the external sphere
  P_amplitude = R*rho*a_amplitude; # pressure amplitude
  nref=2;
  nlayers=40;
  tolerance = Ro/(nlayers)/100
  frequency=1200.; # Hz
  omega=2*pi*frequency;
  dt=1./frequency/20;
  tfinal=90*dt;
  nsteps=round(tfinal/dt)+1;

  # Hexahedral mesh
  fens,fes  =  H8sphere(R,nref);
  fens1,fes1  =  mirrormesh(fens, fes, [-1.0, 0.0, 0.0], [0.0, 0.0, 0.0],
  renumb =  r(c) = c[[1, 4, 3, 2, 5, 8, 7, 6]]);
  fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
  fes = cat(newfes1,fes2)


  # Derive the finite element sets for the boundary
  bfes  =  meshboundary(fes)
  # Outer spherical boundary
  function dout(xyz)
      return xyz/norm(xyz)
  end

  louter = selectelem(fens, bfes, facing = true, direction = dout)
  outer_fes = subset(bfes, louter);

  fens,fes  = H8extrudeQ4(fens, outer_fes,
  nlayers, (xyz, layer)->(R+layer/nlayers*(Ro-R))*xyz/norm(xyz));
  connected = findunconnnodes(fens, fes);
  fens, new_numbering = compactnodes(fens, connected);
  fess = renumberconn!(fes, new_numbering);

  geom  =  NodalField(fens.xyz)
  P  =  NodalField(zeros(FCplxFlt,size(fens.xyz,1),1))

  bfes  =  meshboundary(fes)

  linner = selectelem(fens, bfes, distance = R, from = [0.0 0.0 0.0],
    inflate = tolerance)
  louter = selectelem(fens, bfes, facing = true, direction = dout)

  numberdofs!(P)

  material = MatAcoustFluid(bulk,rho)
  femm  =  FEMMAcoust(GeoD(fes, GaussRule(3, 2)), material)

  S  =  acousticstiffness(femm, geom, P);
  C  =  acousticmass(femm, geom, P);

  abcfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, louter), GaussRule(2, 2)), material)
  D  =  acousticABC(abcfemm, geom, P);

  # Inner sphere pressure loading
  function dipole(dpdn, xyz, J, label, t)
      n = cross(J[:,1],J[:,2]);
      n = vec(n/norm(n));
      dpdn[1] = -rho*a_amplitude*sin(omega*t)*n[1]
  end

  dipfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, linner), GaussRule(2, 2)), material)

  # Solve
  P0 = deepcopy(P)
  P0.values[:] = 0.0; # initially all pressure is zero
  vP0 = gathersysvec(P0);
  vP1 = zeros(vP0);
  vQ0 = zeros(vP0);
  vQ1 = zeros(vP0);
  t = 0.0;
  P1 = deepcopy(P0);

  fi  =  ForceIntensity(FCplxFlt, 1, (dpdn, xyz, J, label)->dipole(dpdn, xyz, J, label, t));
  La0 = distribloads(dipfemm, geom, P1, fi, 2);

  A = (2./dt)*S + D + (dt/2.)*C;

  step =0;
  while t <= tfinal
    step = step  + 1;
    # println("Time $t ($(step)/$(round(tfinal/dt)+1))")
    t = t+dt;
    fi  =  ForceIntensity(FCplxFlt, 1, (dpdn, xyz, J, label)->dipole(dpdn, xyz, J, label, t));
    La1 = distribloads(dipfemm, geom, P1, fi, 2);
    vQ1 = A\((2/dt)*(S*vQ0)-D*vQ0-C*(2*vP0+(dt/2)*vQ0)+La0+La1);
    vP1 = vP0 + (dt/2)*(vQ0+vQ1);
    vP0 = vP1;
    vQ0 = vQ1;
    P1 = scattersysvec!(P1, vec(vP1));
    P0 = P1;
    La0 = La1;
  end

  @test abs(vP1[1] - (3.0254474104972927e-6 + 0.0im)) < 1.e-10

  # File  =   "sphere_dipole_1.vtk"
  # vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
  #  scalars = [( "realP", real(P1.values))])
  # @async run(`"paraview.exe" $File`)


  true

end
end
using mmmmmmtransientsphere
mmmmmmtransientsphere.test()

module mmmmhhemispheremmmmmm
using FinEtools
using Base.Test
function test()

  # println("Rigid movable hemisphere in  water. Time-dependent simulation.
  # ")
  rho = 1000.*phun("kg/m^3");# mass density of water
  c  = 1.4491e+3*phun("m/s");# sound speed in water
  bulk =  c^2*rho;
  rhos = 2500.*phun("kg/m^3");# mass density of the solid sphere
  a_amplitude=1.*phun("mm/s^2");# amplitude of the  acceleration of the sphere
  R = 5.0*phun("mm"); # radius of the interior sphere
  Ro = 3*R # radius of the external sphere
  P_amplitude = 1000*phun("Pa"); # pressure amplitude
  frequency=200.; # Hz
  omega=2*pi*frequency;
  wavenumber=omega/c;
  angl = 0.0
  front_normal=vec([cos(pi/180*angl),sin(pi/180*angl),0]);
  wavevector=wavenumber*front_normal;
  tshift = 0.0
  uincA=P_amplitude/rho/c/omega; # amplitude of the displacement
  # This is the analytical solution of Hickling and Wang
  uamplHW=P_amplitude/(rho*c^2)./(omega/c)*3/(2*rhos/rho+1);
  # Mesh parameters, geometrical tolerance
  nperR = 8;
  nlayers=nperR;
  tolerance = Ro/(nlayers)/100
  # Time step
  dt = 1./frequency/20;
  tfinal = 9/frequency;
  nsteps = round(tfinal/dt)+1;

  t0  =  time()

  # Hexahedral mesh of the solid sphere
  fens,fes  =  H8spheren(R, nperR);
  r(c) = c[[1, 4, 3, 2, 5, 8, 7, 6]]
  fens1,fes1  =  mirrormesh(fens, fes, [-1.0, 0.0, 0.0], [0.0, 0.0, 0.0],
            renumb = r);
  fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
  fes = cat(newfes1,fes2)
  fens1,fes1  =  mirrormesh(fens, fes, [0.0, -1.0, 0.0], [0.0, 0.0, 0.0],
            renumb = r);
  fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
  fes = cat(newfes1,fes2)
  fens1,fes1  =  mirrormesh(fens, fes, [0.0, 0.0, -1.0], [0.0, 0.0, 0.0],
            renumb = r);
  fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
  fes = cat(newfes1,fes2)

  # Retain only half for the hemisphere
  Solidl = selectelem(fens, fes, box=[-Inf,Inf,-Inf,Inf,0,Inf], inflate=(Ro-R)/nlayers/100);
  # This is the half sphere which is filled with water
  fens1w, fes1w = deepcopy(fens), subset(fes, setdiff(collect(1:count(fes)), Solidl))

  # Find the inertial properties of the solid sphere
  geom  =  NodalField(fens.xyz)
  femm  =  FEMMBase(GeoD(subset(fes, Solidl), GaussRule(3, 2)))
  V = integratefunction(femm, geom, (x) ->  1.0)
    # println("V=$(V/phun("mm^3"))")
  Sx = integratefunction(femm, geom, (x) ->  x[1])
    # println("Sx=$(Sx/phun("mm^4"))")
  Sy = integratefunction(femm, geom, (x) ->  x[2])
    # println("Sy=$(Sy/phun("mm^4"))")
  Sz = integratefunction(femm, geom, (x) ->  x[3])
    # println("Sz=$(Sz/phun("mm^4"))")
  CG = vec([Sx Sy Sz]/V)
    # println("CG=$(CG/phun("mm"))")
  function Iinteg(x)
    (norm(x-CG)^2*eye(3)-(x-CG)*(x-CG)')
  end
  Ixx = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 1])
  Ixy = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 2])
  Ixz = integratefunction(femm, geom, (x) ->  Iinteg(x)[1, 3])
  Iyy = integratefunction(femm, geom, (x) ->  Iinteg(x)[2, 2])
  Iyz = integratefunction(femm, geom, (x) ->  Iinteg(x)[2, 3])
  Izz = integratefunction(femm, geom, (x) ->  Iinteg(x)[3, 3])
  It = [Ixx Ixy Ixz; Ixy Iyy Iyz; Ixz Iyz Izz]
    # println("It=$(It/phun("mm^4"))")
  mass =  V*rhos;
  Inertia = It*rhos;

  # The boundary surface of the solid sphere will now be extruded to form  the
  # layers of fluid around it
  # Outer spherical boundary
  function dout(xyz)
      return xyz/norm(xyz)
  end
  bfes  =  meshboundary(fes)
  louter = selectelem(fens, bfes, facing = true, direction = dout)
  outer_fes = subset(bfes, louter);
  fens, fes  = H8extrudeQ4(fens, outer_fes,
            nlayers, (xyz, layer)->(R+layer/nlayers*(Ro-R))*xyz/norm(xyz));
  fens, newfes1, fes2 =  mergemeshes(fens, fes, fens1w, fes1w, tolerance)
  fes = cat(newfes1, fes2)
  connected = findunconnnodes(fens, fes);
  fens, new_numbering = compactnodes(fens, connected);
  fes = renumberconn!(fes, new_numbering);


  # File  =   "Sphere1.vtk"
  # vtkexportmesh(File, fes.conn, fens.xyz, FinEtools.MeshExportModule.H8)
  # @async run(`"paraview.exe" $File`)

  geom  =  NodalField(fens.xyz)
  P  =  NodalField(zeros(FFlt,size(fens.xyz,1),1))

  bfes  =  meshboundary(fes)

  linner = selectelem(fens, bfes, distance = R, from = [0.0 0.0 0.0],
    inflate = tolerance)
  louter = selectelem(fens, bfes, facing = true, direction = dout)

  # println("Pre-processing time elapsed  =  ",time() - t0,"s")

  t1  =  time()

  numberdofs!(P)

  material = MatAcoustFluid(bulk,rho)
  femm  =  FEMMAcoust(GeoD(fes, GaussRule(3, 2)), material)

  S  =  acousticstiffness(femm, geom, P);
  C  =  acousticmass(femm, geom, P);

  abcfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, louter), GaussRule(2, 2)), material)
  D  =  acousticABC(abcfemm, geom, P);

  # ABC surface pressure loading
  function abcp(dpdn, xyz, J, label, t)
      n = cross(J[:,1],J[:,2]);
      n = vec(n/norm(n));
      arg = (-dot(vec(xyz),vec(wavevector))+omega*(t+tshift));
      dpdn[1] = P_amplitude*cos(arg)*(-dot(vec(n),vec(wavevector)));
  end


  targetfemm  =  FEMMAcoustSurf(GeoD(subset(bfes, linner), GaussRule(2, 2)), material)

  ForceF = GeneralField(zeros(3,1))
  numberdofs!(ForceF)
  TorqueF = GeneralField(zeros(3,1))
  numberdofs!(TorqueF)

  GF = pressure2resultantforce(targetfemm, geom, P, ForceF)
  GT = pressure2resultanttorque(targetfemm, geom, P, TorqueF, CG)

  H = transpose(GF)*(rho/mass)*GF + transpose(GT)*(sparse(rho*inv(Inertia)))*GT;

  Ctild = C + H;

  # Solve
  P0 = deepcopy(P)
  P0.values[:] = 0.0; # initially all pressure is zero
  vP0 = gathersysvec(P0);
  vP1 = zeros(vP0);
  vQ0 = zeros(vP0);
  vQ1 = zeros(vP0);
  t = 0.0;
  P1 = deepcopy(P0);
  tTa1 = zeros(3)
  tAa1 = zeros(3)
  tTa0 = zeros(3)
  tAa0 = zeros(3)
  tTv1 = zeros(3)
  tAv1 = zeros(3)
  tTv0 = zeros(3)
  tAv0 = zeros(3)
  tTu1 = zeros(3)
  tAu1 = zeros(3)
  tTu0 = zeros(3)
  tAu0 = zeros(3)
  tTa_store = zeros(3, nsteps+1)
  tAa_store = zeros(3, nsteps+1)
  tTv_store = zeros(3, nsteps+1)
  tAv_store = zeros(3, nsteps+1)
  tTu_store = zeros(3, nsteps+1)
  tAu_store = zeros(3, nsteps+1)
  t_store = zeros(1, nsteps+1)

  pinc = deepcopy(P)
  pincdd = deepcopy(P)
  pincv = zeros(P.nfreedofs)
  pincddv = zeros(P.nfreedofs)
  p1v = zeros(P.nfreedofs)
  p1 = deepcopy(P)

  function recalculate_incident!(t, pinc, pincdd)
    for j = 1:count(fens)
      arg=(-dot(vec(fens.xyz[j,:]),vec(wavevector))+omega*(t+tshift));# wave along the wavevector
      pinc.values[j] = P_amplitude*sin(arg)
      pincdd.values[j] = -omega^2*P_amplitude*sin(arg)
    end
    return pinc, pincdd
  end

  pinc, pincdd = recalculate_incident!(t, pinc, pincdd)
  L0 = -S*gathersysvec!(pincdd, pincddv) - Ctild*gathersysvec!(pinc, pincv);
  fabcp(dpdn, xyz, J, label) = abcp(dpdn, xyz, J, label, t)
  fi  =  ForceIntensity(FFlt, 1, fabcp);
  La0 = distribloads(abcfemm, geom, P1, fi, 2);

  A = lufact((2./dt)*S + D + (dt/2.)*Ctild);

  step = 1;
  while step <= nsteps
    # println("Time $t ($(step)/$(Int(round(tfinal/dt))+1))")
    # Store for output
    tTa_store[:, step] = tTa1
    tAa_store[:, step] = tAa1
    tTv_store[:, step] = tTv1
    tAv_store[:, step] = tAv1
    tTu_store[:, step] = tTu1
    tAu_store[:, step] = tAu1
    t_store[1, step] = t
    # New loads and update
    step = step  + 1;
    t = t+dt;
    pinc, pincdd = recalculate_incident!(t, pinc, pincdd)
    L1 = -S*gathersysvec!(pincdd, pincddv) - Ctild*gathersysvec!(pinc, pincv);
    fabcp(dpdn, xyz, J, label) = abcp(dpdn, xyz, J, label, t)
    fi  =  ForceIntensity(FFlt, 1, fabcp);
    La1 = distribloads(abcfemm, geom, P1, fi, 2);
    vQ1 = A\((2/dt)*(S*vQ0)-D*vQ0-Ctild*(2*vP0+(dt/2)*vQ0)+L0+L1+La0+La1);
    vP1 = vP0 + (dt/2)*(vQ0+vQ1);
    P1 = scattersysvec!(P1, vec(vP1));
    p1.values[:] = P1.values[:] + pinc.values[:]
    p1v = gathersysvec!(p1, p1v);
    Fresultant = GF*p1v;
    Tresultant = GT*p1v;
    # println("Fresultant = $Fresultant")
    tTa1 = Fresultant/mass; tAa1 = Inertia\Tresultant;
    # Update  the velocity and position of the rigid body
    tTv1 = tTv0 + dt/2*(tTa0+tTa1);
    tTu1 = tTu0 + dt/2*(tTv0+tTv1);
    tAv1 = tAv1 + dt/2*(tAa0+tAa1);
    tAu1 = tAu0 + dt/2*(tAv0+tAv1);
    # show(tTa1)
    # Reset for the next time step
    copy!(vP0, vP1);
    copy!(vQ0, vQ1);
    P0 = deepcopy(P1);
    copy!(L0, L1);
    copy!(La0, La1);
    copy!(tTa0, tTa1); copy!(tAa0, tAa1)
    copy!(tTv0, tTv1); copy!(tAv0, tAv1)
    copy!(tTu0, tTu1); copy!(tAu0, tAu1)
  end
  tTa_store[:, step] = tTa1
  tAa_store[:, step] = tAa1
  tTv_store[:, step] = tTv1
  tAv_store[:, step] = tAv1
  tTu_store[:, step] = tTu1
  tAu_store[:, step] = tAu1
  t_store[1, step] = t

  function remove_bias(it, iy)
    local t = deepcopy(reshape(it,length(it),1))
    local y = deepcopy(reshape(iy,length(iy),1))
    t = t/mean(t);
    t = reshape(t,length(t),1);
    y = reshape(y,length(y),1);
    local B = [t ones(t)];
    local p = (B'*B)\(B'*y);
    return y-p[1]*t-p[2];
  end

  ux = remove_bias(t_store, tTu_store[1,:])

  function find_peaks(t,y)
      p=Float64[];
      dy=diff(y);
      for j3=1:length(dy)-1
          if (dy[j3]*dy[j3+1]<0)
              push!(p, y[j3+1]);
          end
      end
      return p
  end
  function amplitude(t,y)
      p= find_peaks(t,y) ;
      A=mean(abs.(p)) ;
      return A
  end
  # println("Normalized amplitude  = $(amplitude(t_store,ux)/uamplHW)")
@test abs(amplitude(t_store,ux)/uamplHW-0.9361240886218495) < 1.0e-5
  # using Plots
  # plotly()
  # plot(transpose(t_store), transpose(tTu_store)/phun("mm"),
  #  xlabel = "t", ylabel = "Displacement", label = "Displacements")
  # plot(transpose(t_store), transpose(tAu_store),
  #  xlabel = "t", ylabel = "Displacement", label = "Rotations")
  # # plot(transpose(t_store), (ux)/uamplHW,
  # #  xlabel = "t", ylabel = "Normalized displacement", label = "Rectified")
  # gui()
  #
  # #
  # File  =   "hemisphere_final_td1.vtk"
  # vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
  #  scalars = [( "realP", real(P1.values))])
  # @async run(`"paraview.exe" $File`)

end
end
using mmmmhhemispheremmmmmm
mmmmhhemispheremmmmmm.test()

module mmmmmmbbaffledmmmm
using FinEtools
using Base.Test
function test()
rho = 1.21*phun("kg/m^3");# mass density
c  = 343.0*phun("m/s");# sound speed
bulk =  c^2*rho;
omega =  7500*phun("rev/s");      # frequency of the piston
a_piston =  -1.0*phun("mm/s")     # amplitude of the piston acceleration
R = 50.0*phun("mm");# radius of the piston
Ro = 150.0*phun("mm"); # radius of the enclosure
nref = 3;#number of refinements of the sphere around the piston
nlayers = 25;                     # number of layers of elements surrounding the piston
tolerance = R/(2^nref)/100

# println("""
#
# Baffled piston in a half-sphere domain with ABC.
#
# Hexahedral mesh. Algorithm version.
# """)

t0  =  time()

# Hexahedral mesh
fens,fes  =  H8sphere(R,nref);
bfes  =  meshboundary(fes)
# File  =   "baffledabc_boundary.vtk"
# vtkexportmesh(File, bfes.conn, fens.xyz, FinEtools.MeshExportModule.Q4)
#  @async run(`"paraview.exe" $File`)

l = selectelem(fens,bfes,facing = true,direction = [1.0 1.0  1.0])
ex(xyz, layer) = (R+layer/nlayers*(Ro-R))*xyz/norm(xyz)
fens1,fes1  =  H8extrudeQ4(fens, subset(bfes,l), nlayers, ex);
fens,newfes1,fes2 =  mergemeshes(fens1, fes1, fens, fes, tolerance)
fes = cat(newfes1,fes2)

# Piston surface mesh
bfes  =  meshboundary(fes)
l1 = selectelem(fens, bfes, facing = true, direction = [-1.0 0.0 0.0])
l2 = selectelem(fens, bfes, distance = R, from = [0.0 0.0 0.0], inflate = tolerance)
piston_fes = subset(bfes,intersect(l1,l2));

# Outer spherical boundary
louter = selectelem(fens, bfes, facing = true, direction = [1.0 1.0  1.0])
outer_fes = subset(bfes,louter);

# println("Pre-processing time elapsed  =  ",time() - t0,"s")

t1  =  time()

material = MatAcoustFluid(bulk, rho)
# Region of the fluid
region1 =  FDataDict("femm"=>FEMMAcoust(GeoD(fes, GaussRule(3, 2)), material))

# Surface for the ABC
abc1  =  FDataDict("femm"=>FEMMAcoustSurf(GeoD(outer_fes, GaussRule(2, 2)),
          material))

# Surface of the piston
flux1  =  FDataDict("femm"=>FEMMAcoustSurf(GeoD(piston_fes, GaussRule(2, 2)),
          material),  "normal_flux"=> -rho*a_piston+0.0im);

# Make model data
modeldata =  FDataDict("fens"=>  fens,
                 "omega"=>omega,
                 "regions"=>[region1],
                 "flux_bcs"=>[flux1], "ABCs"=>[abc1])

# Call the solver
modeldata = FinEtools.AlgoAcoustModule.steadystate(modeldata)

# println("Computing time elapsed  =  ",time() - t1,"s")
# println("Total time elapsed  =  ",time() - t0,"s")

geom = modeldata["geom"]
P = modeldata["P"]

@test abs(P.values[1]-(4.355914465396856e-6 - 1.2061599990585114e-6im)) < 1.e-10
# File  =   "baffledabc.vtk"
# vtkexportmesh(File, fes.conn, geom.values, FinEtools.MeshExportModule.H8;
# scalars = [("absP", abs.(P.values))])
# @async run(`"paraview.exe" $File`)

# using Winston
# pl  =  FramedPlot(title = "Matrix",xlabel = "x",ylabel = "Re P, Im P")
# setattr(pl.frame, draw_grid = true)
# add(pl, Curve([1:length(C[:])],vec(C[:]), color = "blue"))

# # pl = plot(geom.values[nLx,1][ix],scalars[nLx][ix])
# # xlabel("x")
# # ylabel("Pressure")
# display(pl)

true
end
end
using mmmmmmbbaffledmmmm
mmmmmmbbaffledmmmm.test()
