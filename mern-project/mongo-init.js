// =============================================================================
// MongoDB Başlangıç Seed Verisi
// Bu script sadece ilk kez container oluşturulduğunda çalışır
// Docker entrypoint tarafından otomatik olarak yürütülür
// =============================================================================

// sample_training veritabanına geç
db = db.getSiblingDB("sample_training");

// records koleksiyonuna örnek veriler ekle
db.records.insertMany([
    {
        name: "Charlie Brown",
        position: "Full Stack Developer",
        level: "Mid"
    }
]);

print(" Seed verisi başarıyla eklendi");
