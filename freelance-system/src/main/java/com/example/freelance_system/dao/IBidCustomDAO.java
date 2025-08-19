package com.example.freelance_system.dao;

import java.util.Map;

public interface IBidCustomDAO {
    Map<String, Long> getBidOverviewCounts(Long freelancerId);
}
