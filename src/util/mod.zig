const Predicate = fn (comptime T: type, value: anytype) bool;

pub fn count_if(comptime T: type, arr: []T, predicate: Predicate(T)) usize {
    var count: usize = 0;
    for (arr) |item| {
        if (predicate(item)) {
            count += 1;
        }
    }
    return count;
}
