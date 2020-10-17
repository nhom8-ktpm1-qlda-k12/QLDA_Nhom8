use master 
go
drop database QuanLyCuaHang
create database QuanLyCuaHang
go
use QuanLyCuaHang
go
--tao bang--
create table NhaCungCap(
	MaNCC varchar(15) primary key,
	TenNCC nvarchar(30),
	DiaChi nvarchar(50) ,
	SDT int
)
create table LoaiHang(
	MaLoai varchar(15) primary key,
	TenLoai nvarchar(30)
)
create table NhanVien(
	MaNhanVien varchar(15) primary key,
	TenDangNhap varchar(30) unique,
	MatKhau varchar(16),
	HoVaTen nvarchar(30),
	NgaySinh DateTime,
	SoDienThoai int,
	DiaChi nvarchar(30),
	GioiTinh bit,
	QuyenLoi varchar(15)
)
create table Hang(
	MaHang varchar(15) primary key,
	TenHang nvarchar(30),
	SoLuongCon int,
	SoLuongDaBan int,
	DonGiaBan float,
	TinhTrangHang nvarchar(10),
	DonGiaNhap float,
	MaNCC varchar(15),
	MaLoai varchar(15),
	constraint fk_Hang1 foreign key(MaNCC) references NhaCungCap(MaNCC)
	on update cascade
	on delete cascade,
	constraint fk_Hang2 foreign key(MaLoai) references LoaiHang(MaLoai)
	on update cascade
	on delete cascade
)
create table HoaDon(
	MaHoaDon varchar(15) primary key,
	NgayLap datetime,
	MaNV varchar(15),
	constraint fk_HoaDon foreign key (MaNV) references NhanVien(MaNhanVien)
	on update cascade
	on delete cascade
)
create table ChiTietHoaDon(
	MaHoaDon varchar(15),
	MaHang varchar(15),
	SoLuongBan int,
	constraint fk_ChiTietHoaDon1 primary key(MaHoaDon,MaHang),
	constraint fk_ChiTietHoaDon2 
	foreign key(MaHoaDon) references HoaDon(MaHoaDon)
	on update cascade
	on delete cascade,
	constraint fk_ChiTietHoaDon3
	foreign key(MaHang) references Hang(MaHang)
	on delete cascade
	on update cascade
)
create table BaoCaoDoanhThu(
	MaBC varchar(15) primary key,
	MaNV varchar(15),
	NgayLap datetime,
	constraint fk_BCDT foreign key(MaNV) references NhanVien(MaNhanVien)
	on update cascade
	on delete cascade
)
create table ChiTietBaoCao(
	MaHang varchar(15),
	MaBC varchar(15),
	SoLuongDaBan int,
	constraint pk_CTBC1 primary key(MaHang,MaBC),
	constraint fk_CTBC foreign key(MaHang) references Hang(MaHang)
	on delete cascade
	on update cascade,
	constraint fk_CTBC2 foreign key(MaBC) references BaoCaoDoanhThu(MaBC)
	on delete cascade
	on update cascade
)
---them du lieu---
insert into NhaCungCap values('NCC01',N'Kinh Đô',N'Hà Nội',0775467898)
insert into NhaCungCap values('NCC02',N'Thăng Long',N'Hồ Chí Minh',0775982345)
insert into NhaCungCap values('NCC03',N'Chikika',N'Seoul',1123456754)
select * from NhaCungCap
 
 select * from NhaCungCap
 --bang Loai Hang
 insert into LoaiHang values('Loai1',N'Sinh Hoạt')
 insert into LoaiHang values('Loai2',N'Học Tập')
 insert into LoaiHang values('Loai3',N'Thức Ăn Nhanh')

 select * from LoaiHang
 --Bang nhan vien--
 insert into NhanVien values('AD01','Admin','Nhom8ktpm',N'Trần Bích Hạnh','10-23-1987',0937465673,N'Hà Nội',0,'Admin')
 insert into NhanVien values('NV01','Nhom8','Nhom8ktpm',N'Trần Thiên Điệp','10-23-1999',0937466573,N'Hà Nội',1,'Staff')

 select * from NhanVien
 --Bang Hang-
 insert into Hang values('Hang01',N'Bút Chì',230,100,3000,N'Còn',1500,'NCC02','Loai2')
 insert into Hang values('Hang02',N'Tampon',130,20,75000,N'Còn',45000,'NCC03','Loai1')
 insert into Hang values('Hang03',N'Mì Hảo Hảo',0,230,3500,N'Hết',2500,'NCC01','Loai3')
--Bang Hoa Don--
insert into HoaDon values('HD01','1/1/2020','NV01')
insert into HoaDon values('HD02','1/2/2020','AD01')

select * from HoaDon

-- Bang Chi Tiet Hoa Don--
insert into ChiTietHoaDon values('HD01','Hang01',10)
insert into ChiTietHoaDon values('HD01','Hang02',2)

insert into ChiTietHoaDon values('HD02','Hang01',10)
insert into ChiTietHoaDon values('HD02','Hang02',20)

select * from ChiTietHoaDon

-- Bang BaoCaoDoanhThu--
insert into BaoCaoDoanhThu values('BC01','NV01','1/31/2020')
insert into BaoCaoDoanhThu values('BC02','AD01','2/29/2020')
-- Bang Chi Tiet Bao Cao--
insert into ChiTietBaoCao values('Hang01','BC02',100)
insert into ChiTietBaoCao values('Hang02','BC02',20)

--tao trigger---
create trigger trg_CapNhat 
on ChiTietHoaDon
for insert
as
begin
	declare @sSoLuongCon int= (Select SoLuongCon from Hang where MaHang=(select MaHang from inserted)),
	@sSoLuongBaninsert int=(select SoLuongBan from inserted);
	if(@sSoLuongCon-@sSoLuongBaninsert)<0
		begin
		Print(N'Không thể nhỏ hơn 0')
		Rollback tran
		end
	else
		begin
		if(@sSoLuongCon-@sSoLuongBaninsert)=0
			begin
			update Hang
			Set SoLuongCon=SoLuongCon - @sSoLuongBaninsert,
			SoLuongDaBan=SoLuongDaBan + @sSoLuongBaninsert,
			TinhTrangHang=N'Hết'
			where Hang.MaHang=(select MaHang from inserted)
			end
		else
			begin
			update Hang
			Set SoLuongCon=SoLuongCon - @sSoLuongBaninsert,
			SoLuongDaBan=SoLuongDaBan + @sSoLuongBaninsert
			where Hang.MaHang=(select MaHang from inserted)
			end
		end
end
-----
create trigger trg_CapNhapBaoCao
on BaoCaoDoanhThu
for insert
as
begin
	update Hang
	set SoLuongDaBan=0;
end
---- Tạo thủ tục ---
create proc pr_baoCao
@sNgayDau Datetime,
@sNgayCuoi Datetime
as 
	begin
	select MaHang, sum(SoLuongBan) as SoLuongBan
	from HoaDon inner join ChiTietHoaDon
	on HoaDon.MaHoaDon=ChiTietHoaDon.MaHoaDon
	where NgayLap>=@sNgayDau and NgayLap <=@sNgayCuoi
	group by MaHang
	end



exec pr_BaoCao '1/1/2020','3/1/2020'



drop trigger trg_CapNhat
enable trigger trg_CapNhat on ChiTietHoaDon
insert into ChiTietHoaDon values('HD02','Hang01',10)
insert into ChiTietHoaDon values('HD02','Hang02',130)
insert into ChiTietHoaDon values('HD02','Hang03',10)



select * from Hang
select * from ChiTietHoaDon where MaHoaDon='HD02'
select * from HoaDon

select * from NhaCungCap

delete from NhaCungCap where MaNCC='NCC01'

select * from NhanVien

select * from BaoCaoDoanhThu
select * from ChiTietBaoCao

delete from BaoCaoDoanhThu