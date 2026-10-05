# Reflection — Lab 19

**Tên:** Nguyễn Mai Hoàng Thiện
**Cohort:** A20-K4
**Path đã chạy:** lite

---

## Câu hỏi (≤ 200 chữ)

> Trên golden set 50 queries, mode nào thắng ở loại query nào (`exact` /
> `paraphrase` / `mixed`), và tại sao? Khi nào bạn **không** dùng hybrid
> (i.e. khi nào pure BM25 hoặc pure vector là lựa chọn đúng)?

- **Kết quả:** `exact` query: BM25 & Hybrid thắng (96.7%) nhờ exact token match. `mixed` query: Hybrid thắng tuyệt đối (100.0%) nhờ RRF (k=60) tổng hợp thứ hạng từ khóa lẫn ý niệm. Tổng thể Hybrid thắng (78.6%).
- **Tại sao:** BM25 khớp chính xác mã/từ khóa, Vector hiểu ý niệm; RRF bù trừ điểm rank giúp `mixed` đạt tối ưu.
- **Khi không dùng Hybrid:**
  1. **Pure BM25:** Tìm kiếm mã SKU, ID người dùng, log error trace hoặc tên riêng; cần độ trễ siêu thấp (P99 \~6ms so với 55ms của Hybrid) và tiết kiệm chi phí CPU.
  2. **Pure Vector:** Tìm kiếm đa phương tiện (ảnh, thoại) hoặc query hoàn toàn là diễn đạt lại không chứa từ khóa trùng khớp.

---

## Điều ngạc nhiên nhất khi làm lab này

Công thức RRF đơn giản `1 / (k + rank)` kết hợp kết quả của hai mô hình độc lập nhưng đem lại hiệu năng vượt trội hơn hẳn từng phương pháp đơn lẻ.

---

## Bonus challenge

- Đã làm bonus (xem `bonus/`)
- Pair work với: *\<tên đồng đội nếu có>*
